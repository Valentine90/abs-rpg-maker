#==============================================================================
# Game_Character (Parte 1)
#------------------------------------------------------------------------------
# Esta classe trata dos Heróis. Esta é usada como uma superclasse para as 
# classes Game_Player e Game_Event.
#==============================================================================

class Game_Character
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :id                       # ID
  attr_reader   :x                        # coordenada x do mapa (lógica)
  attr_reader   :y                        # coordenada y do mapa (lógica)
  attr_reader   :real_x                   # coordenada x do mapa (real * 128)
  attr_reader   :real_y                   # coordenada y do mapa (real * 128)
  attr_reader   :tile_id                  # ID do Tile (inválido se for 0)
  attr_reader   :character_name           # nome do arquivo do Herói
  attr_reader   :character_hue            # cor do Herói
  attr_reader   :opacity                  # nível de opacidade
  attr_reader   :blend_type               # Sinteticidade
  attr_reader   :direction                # direção
  attr_reader   :pattern                  # molde
  attr_reader   :move_route_forcing       # flag de rota pré-definida
  attr_reader   :through                  # atravessar
  attr_accessor :animation_id             # ID da animação
  attr_accessor :transparent              # flag de transparência
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end
  
  #--------------------------------------------------------------------------
  # Determinar se está se Movendo
  #--------------------------------------------------------------------------
  
  def moving?
    # Aqui acontece uma verificação de movimento, caso as coordenadas reais 
    # sejam diferentes das reais, um movimento está ocorrendo.
    return (@real_x != @x * 128 or @real_y != @y * 128)
  end
  
  #--------------------------------------------------------------------------
  # Determinar se está Pulando
  #--------------------------------------------------------------------------
  
  def jumping?
    # Um pulo estará ocorrendo se o contador de pulo for maior do que 0
    return @jump_count > 0
  end
  
  #--------------------------------------------------------------------------
  # Correção da Posição
  #--------------------------------------------------------------------------
  
  def straighten
    # Ocorre se estiver ocorrendo uma animação de movimento ou se a animação 
    # estiver parada
    if @walk_anime or @step_anime
      # Definir molde como 0
      @pattern = 0
    end
    # Limpar o contador de animação
    @anime_count = 0
    # Limpar direção fixa
    @prelock_direction = 0
  end
  
  #--------------------------------------------------------------------------
  # Rota Pré-Definida
  #
  #     move_route : nova rota de movimento
  #--------------------------------------------------------------------------
  
  def force_move_route(move_route)
    # Salvar rota original
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    # Mudar rota de movimento
    @move_route = move_route
    @move_route_index = 0
    # Definir flag de rota pré-definida
    @move_route_forcing = true
    # Limpar direção fixa
    @prelock_direction = 0
    # Limpar espera
    @wait_count = 0
    # Executar o movimento definido
    move_type_custom
  end
  
  #--------------------------------------------------------------------------
  # Determinar se é Passável
  #
  #     x : coordenada x
  #     y : coordenada y
  #     d : direção (0,2,4,6,8)
  #         * 0 = Determina que todas as direções estão bloqueadas (para pulo)
  #--------------------------------------------------------------------------
  
  def passable?(x, y, d)
    # Selecionar novas coordenadas
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # Se as coordenadas estiverem fora do mapa
    unless $game_map.valid?(new_x, new_y)
      # Impassável
      return false
    end
    # Se atravessar estiver ON
    if @through
      # passável
      return true
    end
    # Se for incapaz executar o primeiro movimento
    unless $game_map.passable?(x, y, d, self)
      # Impassável
      return false
    end
    # Se for incapaz de começar o movimento
    unless $game_map.passable?(new_x, new_y, 10 - d)
      # impassável
      return false
    end
    # Loop para todos os eventos
    for event in $game_map.events.values
      # Se as coordenadas do evento forem coincidentes com o destino do 
      # movimento
      if event.x == new_x and event.y == new_y
        # Se atravessar estiver OFF
        unless event.through
          # Se o evento for automático
          if self != $game_player
            # Impassável
            return false
          end
          # Se o evento estiver para o jogador bem como o Herói para os gráficos
          if event.character_name != ""
            # Impassável
            return false
          end
        end
      end
    end
    # Se as coordenadas do jogador forem coincidentes com o destino do movimento
    if $game_player.x == new_x and $game_player.y == new_y
      # Se atravessar estiver OFF
      unless $game_player.through
        # Se o seu próprio gráfico é um Herói
        if @character_name != ""
          # Impassável
          return false
        end
      end
    end
    # Passável
    return true
  end
  
  #--------------------------------------------------------------------------
  # Fixo
  #--------------------------------------------------------------------------
  
  def lock
    # Se estiver fixo
    if @locked
      # Fim do método
      return
    end
    # Salvar direção fixa
    @prelock_direction = @direction
    # Dár rumo ao jogador
    turn_toward_player
    # Definir flag de fixo
    @locked = true
  end
  
  #--------------------------------------------------------------------------
  # Determinar se está fixo
  #--------------------------------------------------------------------------
  
  def lock?
    return @locked
  end
  
  #--------------------------------------------------------------------------
  # Remover
  #--------------------------------------------------------------------------
  
  def unlock
    # Se não estiver fixo
    unless @locked
      # Fim do método
      return
    end
    # Limpar flag de fixo
    @locked = false
    # Se a direção não estiver fixada
    unless @direction_fix
      # Se a direção fixa estiver salva
      if @prelock_direction != 0
        # Recuperar direção fixa
        @direction = @prelock_direction
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover para uma Posição Designada
  #     x : coordenada x
  #     y : coordenada y
  #--------------------------------------------------------------------------
  
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Coordenada X da Tela
  #--------------------------------------------------------------------------
  
  def screen_x
    # Selecionar as coordenadas a partir das coordenadas reais e da posição 
    # exibida no mapa
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Coordenada Y da Tela
  #--------------------------------------------------------------------------
  
  def screen_y
    # Selecionar as coordenadas a partir das coordenadas reais e da posição 
    # exibida no mapa
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    # Criar coordenadas y via contador de pulo
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Coordenada Z da Tela
  #
  #     height : altura do Peronagem
  #--------------------------------------------------------------------------
  
  def screen_z(height = 0)
    # Se a flag de exibição na superfície mais próxima estiver ON
    if @always_on_top
      # 999, incondicional
      return 999
    end
    # Selecionar as coordenadas a partir das coordenadas reais e da posição 
    # exibida no mapa
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    # Se for tile
    if @tile_id > 0
      # Adicionar uma prioridade de tile * 32
      return z + $game_map.priorities[@tile_id] * 32
    # Se for Herói
    else
      # Se a altura exceder 32, então aqui é adicionado mais 31
      return z + ((height > 32) ? 31 : 0)
    end
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Profundidade do Gramado
  #--------------------------------------------------------------------------
  
  def bush_depth
    # Se o tile, ou a flag de exibição na superfície mais próxima estiver ON
    if @tile_id > 0 or @always_on_top
      return 0
    end
    # Se estiver ocorrendo o pulo, então = 12; o restante = 0
    if @jump_count == 0 and $game_map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Tag de Terreno
  #--------------------------------------------------------------------------
  
  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end
end
