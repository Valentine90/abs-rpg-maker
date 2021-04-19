#==============================================================================
# Game_Map
#------------------------------------------------------------------------------
# Esta classe engloba o mapa. Isso determina o Scroll e a determinante de 
# passagem. Se refere a $game_map para as instâncias desta classe.
#==============================================================================

class Game_Map
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_accessor :tileset_name             # nome do arquivo de Tileset
  attr_accessor :autotile_names           # nome no arquivo de Autotile
  attr_accessor :panorama_name            # nome do arquivo de Panorama
  attr_accessor :panorama_hue             # cor do Panorama
  attr_accessor :fog_name                 # nome do arquivo de Névoa
  attr_accessor :fog_hue                  # cor da névoa
  attr_accessor :fog_opacity              # nível de opacidade da Névoa
  attr_accessor :fog_blend_type           # método de combinação de Névoa
  attr_accessor :fog_zoom                 # magnitude de Névea
  attr_accessor :fog_sx                   # sx de Névoa (velocidade x)
  attr_accessor :fog_sy                   # sx de Névoa (velocidade y)
  attr_accessor :battleback_name          # nome do arquivo de Fundo de Batalha
  attr_accessor :display_x                # mostrar coordena x * 128
  attr_accessor :display_y                # mostrar coordena y * 128
  attr_accessor :need_refresh             # atualizar flag requerida
  attr_reader   :passages                 # terreno passável
  attr_reader   :priorities               # prioridade do terreno
  attr_reader   :terrain_tags             # Tag do terreno
  attr_reader   :events                   # Eventos
  attr_reader   :fog_ox                   # Início da coordenada x de Névoa
  attr_reader   :fog_oy                   # início da coordenada y de Névoa
  attr_reader   :fog_tone                 # cor da Névoa
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
  end
  
  #--------------------------------------------------------------------------
  # Configurar
  #     map_id : ID do mapa
  #--------------------------------------------------------------------------
  
  def setup(map_id)
    # Colocar ID do mapa na memória de @map_id
    @map_id = map_id
    # Carregar mapa pelo arquivo e definir @map
    @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
    # Definir informação do Tileset na abertura da variáveis de instãncia
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    # Inicializar coordenadas exibidas
    @display_x = 0
    @display_y = 0
    # Limpar atualização da flag requerida
    @need_refresh = false
    # Definir dados dos Eventos do mapa
    @events = {}
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    # Definir dados dos Eventos Comuns do mapa
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
    # Inicializar todas as informações de Névoa
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    # Inicializar informação do scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
  
  #--------------------------------------------------------------------------
  # Selecionar ID do Mapa
  #--------------------------------------------------------------------------
  
  def map_id
    return @map_id
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Largura
  #--------------------------------------------------------------------------
  
  def width
    return @map.width
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Altura
  #--------------------------------------------------------------------------
  
  def height
    return @map.height
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Lista de Encontros
  #--------------------------------------------------------------------------
  
  def encounter_list
    return @map.encounter_list
  end
  
  #--------------------------------------------------------------------------
  # selecionar Passos para o Encontro
  #--------------------------------------------------------------------------
  
  def encounter_step
    return @map.encounter_step
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Dados do Mapa
  #--------------------------------------------------------------------------
  
  def data
    return @map.data
  end
  
  #--------------------------------------------------------------------------
  # Mudança Automática de BGM e BGS de Fundo
  #--------------------------------------------------------------------------
  
  def autoplay
    if @map.autoplay_bgm
      $game_system.bgm_play(@map.bgm)
    end
    if @map.autoplay_bgs
      $game_system.bgs_play(@map.bgs)
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    # Se o ID do mapa for válido
    if @map_id > 0
      # Atualizar todos os Eventos do mapa
      for event in @events.values
        event.refresh
      end
      # Atualizar todos os Eventos comuns do mapa
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    # Limpar atualização da flag requerida
    @need_refresh = false
  end
  
  #--------------------------------------------------------------------------
  # Scroll para Baixo
  #
  #     distance : distância do scroll
  #--------------------------------------------------------------------------
  
  def scroll_down(distance)
    @display_y = [@display_y + distance, (self.height - 15) * 128].min
  end
  
  #--------------------------------------------------------------------------
  # Scroll para Esquerda
  #
  #     distance : distância do scroll
  #--------------------------------------------------------------------------
  
  def scroll_left(distance)
    @display_x = [@display_x - distance, 0].max
  end
  
  #--------------------------------------------------------------------------
  # Scroll para Direita
  #
  #     distance : distância do scroll
  #--------------------------------------------------------------------------
  
  def scroll_right(distance)
    @display_x = [@display_x + distance, (self.width - 20) * 128].min
  end
  
  #--------------------------------------------------------------------------
  # Scroll para Cima
  #
  #     distance : distância do scroll
  #--------------------------------------------------------------------------
  
  def scroll_up(distance)
    @display_y = [@display_y - distance, 0].max
  end
  
  #--------------------------------------------------------------------------
  # Determinar as Coordenadas Válidas
  #
  #     x          : coordenada x
  #     y          : coordenada y
  #--------------------------------------------------------------------------
  
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  
  #--------------------------------------------------------------------------
  # Determinar se é Passável
  #
  #     x          : coordenada x
  #     y          : coordenada y
  #     d          : direção (0,2,4,6,8,10)
  #                  *  0,10 = determina se todas as direções são passáveis
  #     self_event : automático (se o Evento for determinado passável)
  #--------------------------------------------------------------------------
  
  def passable?(x, y, d, self_event = nil)
    # Se as coordenadas dadas forem fora do mapa
    unless valid?(x, y)
      # Impasável
      return false
    end
    # Mudar direção (0,2,4,6,8,10) para bloqueado (0,1,2,4,8,0)
    bit = (1 << (d / 2 - 1)) & 0x0f
    # Loop em todos os Eventos
    for event in events.values
      # Se os Tiles forem outros que automático e as coordenas coincidirem
      if event.tile_id >= 0 and event != self_event and
         event.x == x and event.y == y and not event.through
        # Se for bloqueado
        if @passages[event.tile_id] & bit != 0
          # Impassável
          return false
        # se for um bloqueado em todas as direções
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          # Impassável
          return false
        # Se as prioridades forem outras que 0
        elsif @priorities[event.tile_id] == 0
          # Passável
          return true
        end
      end
    end
    # Loop procura a ordem do layer de topo
    for i in [2, 1, 0]
      # Selecionar o ID do Tile
      tile_id = data[x, y, i]
      # Se houver falha na aquisição do Tile
      if tile_id == nil
        # Impassável
        return false
      # Se for 
      elsif @passages[tile_id] & bit != 0
        # Impassável
        return false
      # Se for bloqueado em todas as direções
      elsif @passages[tile_id] & 0x0f == 0x0f
        # Impassável
        return false
      # Se as prioridades forem outras que 0
      elsif @priorities[tile_id] == 0
        # Passável
        return true
      end
    end
    # Passável
    return true
  end
  
  #--------------------------------------------------------------------------
  # Determinar Gramado
  #
  #     x          : coordenada x
  #     y          : coordenada y
  #--------------------------------------------------------------------------
  
  def bush?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x40 == 0x40
          return true
        end
      end
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Determinar Balcão
  #
  #     x          : coordenada x
  #     y          : coordenada y
  #--------------------------------------------------------------------------
  
  def counter?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x80 == 0x80
          return true
        end
      end
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Definir Tag do Terreno
  #
  #     x          : coordenada x
  #     y          : coordenada y
  #--------------------------------------------------------------------------
  
  def terrain_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return 0
        elsif @terrain_tags[tile_id] > 0
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Posição Designada do ID de Evento
  #
  #     x          : coordenada x
  #     y          : coordenada y
  #--------------------------------------------------------------------------
  
  def check_event(x, y)
    for event in $game_map.events.values
      if event.x == x and event.y == y
        return event.id
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Iniciar Scroll
  #
  #     direction : direcção do scroll
  #     distance  : distância do scroll
  #     speed     : velocidade do scroll
  #--------------------------------------------------------------------------
  
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 128
    @scroll_speed = speed
  end
  
  #--------------------------------------------------------------------------
  # Determinar se está Ocorrendo o Scroll
  #--------------------------------------------------------------------------
  
  def scrolling?
    return @scroll_rest > 0
  end
  
  #--------------------------------------------------------------------------
  # Inicar Mudança de Cor de Névoa
  #
  #     tone     : cor
  #     duration : tempo
  #--------------------------------------------------------------------------
  
  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    if @fog_tone_duration == 0
      @fog_tone = @fog_tone_target.clone
    end
  end
  
  #--------------------------------------------------------------------------
  # Inicar Mudança do Nível de Opacidade de Névoa
  #
  #     opacity  : nível de opacidade
  #     duration : tempo
  #--------------------------------------------------------------------------
  
  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity * 1.0
    @fog_opacity_duration = duration
    if @fog_opacity_duration == 0
      @fog_opacity = @fog_opacity_target
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  def update
    # Atualizar o mapa se necessário
    if $game_map.need_refresh
      refresh
    end
    # Se estiver ocorrendo o scroll
    if @scroll_rest > 0
      # Mudar da velocidade de scroll para as coordenadas de distância do mapa
      distance = 2 ** @scroll_speed
      # Executar scroll
      case @scroll_direction
      when 2  # Baixo
        scroll_down(distance)
      when 4  # Esquerda
        scroll_left(distance)
      when 6  # Direita
        scroll_right(distance)
      when 8  # Cima
        scroll_up(distance)
      end
      # Subtrair a distância do scroll
      @scroll_rest -= distance
    end
    # Atualizar Evento do mapa
    for event in @events.values
      event.update
    end
    # Atualizar Evento Comum do mapa
    for common_event in @common_events.values
      common_event.update
    end
    # Controlar scroll da Névoa
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    # Controlar a mudança de cor de Névoa
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    # Controlar a mudança de nível de opacidade de Névoa
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
end
