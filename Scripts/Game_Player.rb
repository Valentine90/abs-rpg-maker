#==============================================================================
# Game_Player
#------------------------------------------------------------------------------
# Esta classe engloba o Jogador. Suas funções incluem a inicialização das 
# determinantes dos eventos e o scroll do mapa. Se refere a "$game_player" para 
# as instâncias desta classe.
#==============================================================================

class Game_Player < Game_Character
  
  #--------------------------------------------------------------------------
  # Constantes
  #--------------------------------------------------------------------------
  
  CENTER_X = (320 - 16) * 4   # Coordenada X do centro da tela * 4
  CENTER_Y = (240 - 16) * 4   # Coordenada Y do centro da tela * 4
  
  #--------------------------------------------------------------------------
  # Determinantes de Passagem
  #     x : coordenada x
  #     y : coordenada y
  #     d : direção (0,2,4,6,8)
  #         * 0 = Determina que todas as direção estão bloqueadas (para pulos)
  #--------------------------------------------------------------------------
  
  def passable?(x, y, d)
    # Selecionar as novas coordenadas
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # Se as coordenadas estiverem para fora do mapa
    unless $game_map.valid?(new_x, new_y)
      # Impassável
      return false
    end
    # Se o Modo de Depuração estiver ON e a tecla Ctrl for pressioanda
    if $DEBUG and Input.press?(Input::CTRL)
      # Passável
      return true
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # Definir a Exibição do Mapa para o Centro da Tela
  #--------------------------------------------------------------------------
  
  def center(x, y)
    max_x = ($game_map.width - 20) * 128
    max_y = ($game_map.height - 15) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
  
  #--------------------------------------------------------------------------
  # Mover para uma Posição Designada
  #     x : coordenada x
  #     y : coordenada y
  #--------------------------------------------------------------------------
  
  def moveto(x, y)
    super
    # Aqui a tela é centralizada
    center(x, y)
    # Criar o contador de encontros
    make_encounter_count
  end
  
  #--------------------------------------------------------------------------
  # Acrescentar Passos
  #--------------------------------------------------------------------------
  
  def increase_steps
    super
    # Se o movimento não for Pré-Definido
    unless @move_route_forcing
      # Acrescentar passos
      $game_party.increase_steps
      # Se o número de passos for par
      if $game_party.steps % 2 == 0
        # Verificar se recebeu dano
        $game_party.check_map_slip_damage
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Selecionar o Contador de Encontros
  #--------------------------------------------------------------------------
  
  def encounter_count
    return @encounter_count
  end
  
  #--------------------------------------------------------------------------
  # Criar o Contadar de Encontros
  #--------------------------------------------------------------------------
  
  def make_encounter_count
    # Aqui dois números randômicos são gerados, e somados a 1
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualizar
  #--------------------------------------------------------------------------
  
  def refresh
    # Se o número de membros no Grupo de Heróis for 0
    if $game_party.actors.size == 0
      # Limpar o nome do arquivo e a tonalidade do Herói
      @character_name = ""
      @character_hue = 0
      # Fim do método
      return
    end
    # Selecionar o Herói líder
    actor = $game_party.actors[0]
    # Selecionar o nome do arquivo e a tonalidade do Herói
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    # Inicializar a opacidade e a sinteticidade
    @opacity = 255
    @blend_type = 0
  end
  
  #--------------------------------------------------------------------------
  # Determinante de Inicialização Sobre o Evento
  #--------------------------------------------------------------------------
  
  def check_event_trigger_here(triggers)
    result = false
    # Se o Evento estiver ocorrendo
    if $game_system.map_interpreter.running?
      return result
    end
    # Fazer o loop de todos os Eventos
    for event in $game_map.events.values
      # Se as coordenadas do Evento e acionadores forem consistentes
      if event.x == @x and event.y == @y and triggers.include?(event.trigger)
        # Se a determinante de inicio for estar na mesma posição do Evento
        # Sendo que não pode estar pulando
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # Determinante de Inicialização na Frente do Evento
  #--------------------------------------------------------------------------
  
  def check_event_trigger_there(triggers)
    result = false
    # Se o Evento estiver ocorrendo
    if $game_system.map_interpreter.running?
      return result
    end
    # Calcular as coordenadas das frentes do Evento
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # Fazer o loop de todos os Eventos
    for event in $game_map.events.values
      # Se as coordenadas do Evento e os acionadores forem consistentes
      if event.x == new_x and event.y == new_y and
         triggers.include?(event.trigger)
        # Se a determinante de inicio for estar na mesma posição do Evento
        # Sendo que não pode estar pulando
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    # Se o Evento adequado não for encontrado
    if result == false
      # Se o tile das frentes for um Balcão
      if $game_map.counter?(new_x, new_y)
        # Calcular se o Balcão está dentro das coordenadas, então, discontá-lo
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # Fazer o loop de todos os Eventos
        for event in $game_map.events.values
          # Se as coordenadas do Evento e os acionadores forem consistentes
          if event.x == new_x and event.y == new_y and
             triggers.include?(event.trigger)
            # Se a determinante de inicio for estar na mesma posição do Evento
            # Sendo que não pode estar pulando
            if not event.jumping? and not event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # Determinante de Inicialização ao Tocar o Evento
  #--------------------------------------------------------------------------
  
  def check_event_trigger_touch(x, y)
    result = false
    # Se o Evento estiver ocorrendo
    if $game_system.map_interpreter.running?
      return result
    end
    # Fazer o loop de todos os Eventos
    for event in $game_map.events.values
      # Se as coordenadas do Evento e os acionadores forem consistentes
      if event.x == x and event.y == y and [1,2].include?(event.trigger)
        # Se a determinante de inicio for estar na mesma posição do Evento
        # Sendo que não pode estar pulando
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Memorizar, se estiver movendo ou não, nas variáveis locais
    last_moving = moving?
    # Se estiver movendo, um evento ocorrendo, uma rota pré-determinada, ou
    # se estiver exibindo uma mensagem
    # Mostrar tudo como se não estivessem ocorrendo
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # Mover o Jogador na direção que o direcional for pressionado
      case Input.dir4
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
    # Memorizar as coordenadas nas variáveis locais
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # Se o Herói for movido para baixo e tenha ficado abaixo do centro da tela
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      # Rolar o mapa para baixo
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # Se o Herói for movido para a esquerda e tenha ficado a esquerda do centro 
    # da tela
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      # Rolar o mapa para a esquerda
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # Se o Herói for movido para a direita e tenha ficado a direita do centro da
    # tela
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      # Rolar o mapa para a direita
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # Se o Herói for movido para cima e tenha ficado acima do centro da tela
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      # rolar o mapa para cima
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # Se não estiver movendo
    unless moving?
      # Se o jogador estava se movendo
      if last_moving
        # Se a determinante de incialização for por toque ou mesma posição
        result = check_event_trigger_here([1,2])
        # Se o Evento que foi iniciado não existir
        if result == false
          # Desconsiderar se o Modo de Depuração estiver ON e a tecla Ctrl
          # pressionada
          unless $DEBUG and Input.press?(Input::CTRL)
            # Diminuir 1 do contador de encontros
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end
        end
      end
      # Se o botão C for pressionado
      if Input.trigger?(Input::C)
        # Determinantes de mesma posição e na frente do Evento
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
  end
end
