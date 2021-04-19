#==============================================================================
# Game_Character (Parte 2)
#------------------------------------------------------------------------------
# Esta classe trata dos Heróis. Esta é usada como uma superclasse para as 
# classes Game_Player e Game_Event.
#==============================================================================

class Game_Character
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Ramificações com pulo, movimento e parada
    if jumping?
      update_jump
    elsif moving?
      update_move
    else
      update_stop
    end
    # Se o contador de animações exceder o valor máximo
    # * Valor máximo é velocidade de movimento * 1 a partir do valor base 18
    if @anime_count > 18 - @move_speed * 2
      # Se parar a animação estiver OFF durante a parada
      if not @step_anime and @stop_count > 0
        # Retornar ao volar do molde original
        @pattern = @original_pattern
      # Se parar a animação estiver ON durante a parada
      else
        # Atualizar molde
        @pattern = (@pattern + 1) % 4
      end
      # Limpar o contador de animações
      @anime_count = 0
    end
    # Se estiver esperando
    if @wait_count > 0
      # Reduzir a espera
      @wait_count -= 1
      return
    end
    # Se for uma rota pré-definida
    if @move_route_forcing
      # Executar o movimento definido
      move_type_custom
      return
    end
    # Quando estiver esperando a execução de um evento ou for fixo
    if @starting or lock?
      # Não se movimenta por si mesmo
      return
    end
    # Se o contador de parada exceder um certo valor 
    # (calculado pela freqüência do movimento)
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      # Ramificação pelo tipo de movimento
      case @move_type
      when 1  # Aleatório
        move_type_random
      when 2  # Seguir Herói
        move_type_toward_player
      when 3  # Pré-Definido
        move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # Atualização do Frame (Pulo)
  #--------------------------------------------------------------------------
  def update_jump
    # Reduzir o contador de pulo em 1
    @jump_count -= 1
    # Calcular novas coordenadas
    @real_x = (@real_x * @jump_count + @x * 128) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 128) / (@jump_count + 1)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Movimento)
  #--------------------------------------------------------------------------
  
  def update_move
    # Converter as coordenadas do mapa pela velocidade do mapa na distância do 
    # movimento
    distance = 2 ** @move_speed
    # Se as coordenadas lógicas estiverem mais para baixo do que as coordenadas 
    # reais
    if @y * 128 > @real_y
      # Mover para baixo
      @real_y = [@real_y + distance, @y * 128].min
    end
    # Se as coordenadas lógicas estiverem mais para a esquerda do que as 
    # coordenadas reais
    if @x * 128 < @real_x
      # Mover para a esquerda
      @real_x = [@real_x - distance, @x * 128].max
    end
    # Se as coordenadas lógicas estiverem mais para a direita do que as 
    # coordenadas reais
    if @x * 128 > @real_x
      # Mover para a direita
      @real_x = [@real_x + distance, @x * 128].min
    end
    # Se as coordenadas lógicas estiverem mais para cima do que as coordenadas 
    # reais
    if @y * 128 < @real_y
      # Mover para cima
      @real_y = [@real_y - distance, @y * 128].max
    end
    # Se a animação do movimento estiver ON
    if @walk_anime
      # Acrescentar o contador de animação em 1.5
      @anime_count += 1.5
    # Se a animação de movimento estiver OFF e a animação parada estiver ON
    elsif @step_anime
      # Acrescentar o contador de animação em 1
      @anime_count += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Parada)
  #--------------------------------------------------------------------------
  
  def update_stop
    # Se a animação parada estiver ON
    if @step_anime
      # Acrescentar o contador de animação em 1
      @anime_count += 1
    # Se a parada de animação estiver OFF, mas o molde atual é diferente
    elsif @pattern != @original_pattern
      # Acrescentar o contador de animação em 1.5
      @anime_count += 1.5
    end
    # Quando estiver esperando pela exucução do evento ou for não fixo
    # * Se fixo combinar com uma execução de evento causara um travamento
    unless @starting or lock?
      # Acrescentar o contador de parada em 1
      @stop_count += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # Tipo de Movimento: Aleatório
  #--------------------------------------------------------------------------
  
  def move_type_random
    # Ramificação por números aleatórios de 0-5
    case rand(6)
    when 0..3  # Aleatório
      move_random
    when 4  # Avançar um passo
      move_forward
    when 5  # Parada temporária
      @stop_count = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Tipo de Movimento: Seguir Herói
  #--------------------------------------------------------------------------
  
  def move_type_toward_player
    # Selecionar a diferença nas coordenadas do jogador
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Aqui é determinada a diferença
    abs_sx = sx > 0 ? sx : -sx
    abs_sy = sy > 0 ? sy : -sy
    # Se forem separados por 20 ou mais tiles, contando horizontalmente e verticalmente
    if sx + sy >= 20
      # Movimento Aleatório
      move_random
      return
    end
    # Ramificação por números aleatórios de 0-5
    case rand(6)
    when 0..3  # Seguir Herói
      move_toward_player
    when 4  # Aleatório
      move_random
    when 5  # Avançar um passo
      move_forward
    end
  end
  
  #--------------------------------------------------------------------------
  # Tipo de Movimento: Pré-Definido
  #--------------------------------------------------------------------------
  
  def move_type_custom
    # Interrupção se não estiver parado
    if jumping? or moving?
      return
    end
    # Loop até chegar na lista de comandos de movimento
    while @move_route_index < @move_route.list.size
      # Assimilando os comandos de movimento
      command = @move_route.list[@move_route_index]
      # Se o código for 0 (última parte da lista)
      if command.code == 0
        # Se a opção repetir a ação estiver ON
        if @move_route.repeat
          # Retornar ao primeiro item do índice de movimentos
          @move_route_index = 0
        end
        # Se a opção repetir a ação estiver OFF
        unless @move_route.repeat
          # Se a rota for pré-definida
          if @move_route_forcing and not @move_route.repeat
            # Liberar rota pré-definida
            @move_route_forcing = false
            # Recuperar rota original
            @move_route = @original_move_route
            @move_route_index = @original_move_route_index
            @original_move_route = nil
          end
          # Limpar contador de parada
          @stop_count = 0
        end
        return
      end
      # Durante os comandos de movimento (de mover para baixo para pular)
      if command.code <= 14
        # Ramificação por código de comando
        case command.code
        when 1  # Mover abaixo
          move_down
        when 2  # Mover à esquerda
          move_left
        when 3  # Movr à direita
          move_right
        when 4  # Mover acima
          move_up
        when 5  # Mover esquerda-abaixo
          move_lower_left
        when 6  # Mover direita-abaixo
          move_lower_right
        when 7  # Mover esquerda-acima
          move_upper_left
        when 8  # Mover direita-acima
          move_upper_right
        when 9  # Movimento aleatório
          move_random
        when 10  # Seguir Herói
          move_toward_player
        when 11  # Fugir do Herói
          move_away_from_player
        when 12  # Avançar um passo
          move_forward
        when 13  # Voltar um passo
          move_backward
        when 14  # Pular
          jump(command.parameters[0], command.parameters[1])
        end
        # Se uma falha de movimento ocorrer quando a opção ignorar se impossível
        # estiver OFF
        if not @move_route.skippable and not moving? and not jumping?
          return
        end
        @move_route_index += 1
        return
      end
      # Se for uma espera
      if command.code == 15
        # Definir o tempo de espera
        @wait_count = command.parameters[0] * 2 - 1
        @move_route_index += 1
        return
      end
      # Se for um comando de mudança de direção
      if command.code >= 16 and command.code <= 26
        # Ramificação por código de ca
        case command.code
        when 16  # Olhar abaixo
          turn_down
        when 17  # Olhar à esquerda
          turn_left
        when 18  # Olhar à direita
          turn_right
        when 19  # Olhar acima
          turn_up
        when 20  # Girar 90° à direita
          turn_right_90
        when 21  # Girar 90° à esquerda
          turn_left_90
        when 22  # Girar 180°
          turn_180
        when 23  # Girar 90° aleatório
          turn_right_or_left_90
        when 24  # Giro aleatório
          turn_random
        when 25  # Olhar para o Herói
          turn_toward_player
        when 26  # Girar Herói [contrário]
          turn_away_from_player
        end
        @move_route_index += 1
        return
      end
      # Se for outro comando
      if command.code >= 27
        # Ramificação por código de comando
        case command.code
        when 27  # Switch ON
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28  # Switch OFF
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29  # Mudar velocidade
          @move_speed = command.parameters[0]
        when 30  # Mudar freqüência
          @move_frequency = command.parameters[0]
        when 31  # Animação [MOV] ON
          @walk_anime = true
        when 32  # Animação [MOV] OFF
          @walk_anime = false
        when 33  # Animação Parada ON
          @step_anime = true
        when 34  # Animação Parada OFF
          @step_anime = false
        when 35  # Direção fixa ON
          @direction_fix = true
        when 36  # Direção fixa OFF
          @direction_fix = false
        when 37  # Invisibilidade ON
          @through = true
        when 38  # Invisibilidade OFF
          @through = false
        when 39  # Sempre no topo ON
          @always_on_top = true
        when 40  # Sempre no topo OFF
          @always_on_top = false
        when 41  # Mudar gráfico
          @tile_id = 0
          @character_name = command.parameters[0]
          @character_hue = command.parameters[1]
          if @original_direction != command.parameters[2]
            @direction = command.parameters[2]
            @original_direction = @direction
            @prelock_direction = 0
          end
          if @original_pattern != command.parameters[3]
            @pattern = command.parameters[3]
            @original_pattern = @pattern
          end
        when 42  # Mudar Opacidade
          @opacity = command.parameters[0]
        when 43  # Mudar Sinteticidade
          @blend_type = command.parameters[0]
        when 44  # Reproduzir SE
          $game_system.se_play(command.parameters[0])
        when 45  # Chamar Script
          result = eval(command.parameters[0])
        end
        @move_route_index += 1
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Acrescentar Passos
  #--------------------------------------------------------------------------
  
  def increase_steps
    # Limpar contador de parada
    @stop_count = 0
  end
end
