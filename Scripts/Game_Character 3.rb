#==============================================================================
# Game_Character (Parte 3)
#------------------------------------------------------------------------------
# Esta classe trata dos Heróis. Esta é usada como uma superclasse para as 
# classes Game_Player e Game_Event.
#==============================================================================

class Game_Character
  
  #--------------------------------------------------------------------------
  # Mover Abaixo
  #
  #     turn_enabled : uma flag que permite uma troca de direção
  #--------------------------------------------------------------------------
  
  def move_down(turn_enabled = true)
    # Olhar abaixo
    if turn_enabled
      turn_down
    end
    # Aqui verifica-se se é passável
    if passable?(@x, @y, 2)
      # Olhar abaixo
      turn_down
      # Atualizar coordenadas
      @y += 1
      # Acrescentar passos
      increase_steps
    # Se for impassável
    else
      # Verificar se há um evento ao tocar herói
      check_event_trigger_touch(@x, @y+1)
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover à Esquerda
  #
  #     turn_enabled : uma flag que permite uma troca de direção
  #--------------------------------------------------------------------------
  
  def move_left(turn_enabled = true)
    # Olhar à esquerda
    if turn_enabled
      turn_left
    end
    # Aqui verifica-se se é passável
    if passable?(@x, @y, 4)
      # Olhar à esquerda
      turn_left
      # Atualizar coordenadas
      @x -= 1
      # Acrescentar passos
      increase_steps
    # Se for impassável
    else
      # Verificar se há um evento ao tocar herói
      check_event_trigger_touch(@x-1, @y)
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover à Direita
  #     turn_enabled : uma flag que permite uma troca de direção
  #--------------------------------------------------------------------------
  
  def move_right(turn_enabled = true)
    # Olhar à direita
    if turn_enabled
      turn_right
    end
    # Aqui verifica-se se é passável
    if passable?(@x, @y, 6)
      # Olhar à direita
      turn_right
      # Atualizar coordenadas
      @x += 1
      # Acrescentar passos
      increase_steps
    # Se for impassável
    else
      # Verificar se há um evento ao tocar herói
      check_event_trigger_touch(@x+1, @y)
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover Acima
  #
  #     turn_enabled : uma flag que permite uma troca de direção
  #--------------------------------------------------------------------------
  
  def move_up(turn_enabled = true)
    # Olhar acima
    if turn_enabled
      turn_up
    end
    # Aqui verifica-se se é passável
    if passable?(@x, @y, 8)
      # Olhjar acima
      turn_up
      # Atualizar coordenadas
      @y -= 1
      # Acrescentar passos
      increase_steps
    # Se for impassável
    else
      # Verificar se há um evento ao tocar herói
      check_event_trigger_touch(@x, @y-1)
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover Esquerda-Abaixo
  #--------------------------------------------------------------------------
  
  def move_lower_left
    # Se não estiver em direção fixa
    unless @direction_fix
      # Face para esquerda quando face para direita e Face para baixo quando 
      # face para cima
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    # Quando ir de baixo à esquerda ou da esquerda para baixo for possível
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
      # Atualizar coordenadas
      @x -= 1
      @y += 1
      # Acrescentar passos
      increase_steps
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover Direita-Abaixo
  #--------------------------------------------------------------------------
  
  def move_lower_right
    # Se não estiver em direção fixa
    unless @direction_fix
      # Face para direita quando face para esquerda e face para baixo quando 
      # face para cima
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    # Quando ir de baixo à direita ou da direita para baixo for possível
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
      # Atualizar coordenadas
      @x += 1
      @y += 1
      # Acrescentar passos
      increase_steps
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover Esquerda-Acima
  #--------------------------------------------------------------------------
  
  def move_upper_left
    # Se não estiver em direção fixa
    unless @direction_fix
      # Face para esquerda quando face para direita e face para cima quando face 
      # para baixo
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    # Quando ir de cima à esquerda ou da esquerda para cima dor possível
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
      # Atualizar coordenadas
      @x -= 1
      @y -= 1
      # Acrescentar passos
      increase_steps
    end
  end
  
  #--------------------------------------------------------------------------
  # Mover Direita-Acima
  #--------------------------------------------------------------------------
  
  def move_upper_right
    # Se não estiver em direção fixa
    unless @direction_fix
      # Face para direita quando face para esquerda e face para cima quando face
      # para baixo
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    # Quando ir de cima à direita ou da direita para cima dor possível
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
      # Atualizar coordenadas
      @x += 1
      @y -= 1
      # Acrescentar passos
      increase_steps
    end
  end
  
  #--------------------------------------------------------------------------
  # Movimento Aleatório
  #--------------------------------------------------------------------------
  
  def move_random
    case rand(4)
    when 0  # Mover Abaxio
      move_down(false)
    when 1  # Mover à esquerda
      move_left(false)
    when 2  # Mover à direita
      move_right(false)
    when 3  # Mover Acima
      move_up(false)
    end
  end
  
  #--------------------------------------------------------------------------
  # Seguir Herói
  #--------------------------------------------------------------------------
  
  def move_toward_player
    # Selecionar a diferença nas coordenadas do jogador
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Se as coordenadas forem iguais
    if sx == 0 and sy == 0
      return
    end
    # Aqui é determinada a diferença
    abs_sx = sx.abs
    abs_sy = sy.abs
    # Se as distâncias vertical e horizontal forem as mesmas
    if abs_sx == abs_sy
      # Acrescentar 1 a uma aleatoriamente
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # Se a distância horizontal for a mais longínqua
    if abs_sx > abs_sy
      # Seguir herói, priorizando os movimento direita e esquerda
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # Se a distância vertical for a mais longínqua
    else
      # Seguir herói, priorizando os movimento acima e abaixo
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Fugir do Herói
  #--------------------------------------------------------------------------
  
  def move_away_from_player
    # Selecionar a diferença nas coordenadas do jogador
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Se as coordenadas forem iguais
    if sx == 0 and sy == 0
      return
    end
    # Aqui é determinada a diferença
    abs_sx = sx.abs
    abs_sy = sy.abs
    # Se as distâncias vertical e horizontal forem as mesmas
    if abs_sx == abs_sy
      # Acrescentar 1 a uma aleatoriamente
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # Se a distância horizontal for a mais longínqua
    if abs_sx > abs_sy
      # Fugir do herói, priorizando os movimento direita e esquerda
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # Se a distância vertical for a mais longínqua
    else
      # Fugir do herói, priorizando os movimento acima e abaixo
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Avançar um Paaso
  #--------------------------------------------------------------------------
  
  def move_forward
    case @direction
    when 2
      move_down(false)
    when 4
      move_left(false)
    when 6
      move_right(false)
    when 8
      move_up(false)
    end
  end
  
  #--------------------------------------------------------------------------
  # Voltar um Passo
  #--------------------------------------------------------------------------
  
  def move_backward
    # Memorizar direção
    last_direction_fix = @direction_fix
    # Determinar direção fixa
    @direction_fix = true
    # Ramificação por direção
    case @direction
    when 2  # Abaixo
      move_up(false)
    when 4  # Esquerda
      move_right(false)
    when 6  # Direita
      move_left(false)
    when 8  # Acima
      move_down(false)
    end
    # Aqui a direção fixa volta ao normal
    @direction_fix = last_direction_fix
  end
  
  #--------------------------------------------------------------------------
  # Pular
  #
  #     x_plus : valor a mais da coordenada x
  #     y_plus : valor a mais da coordenada y
  #--------------------------------------------------------------------------
  
  def jump(x_plus, y_plus)
    # Se o valor a mais não for (0,0)
    if x_plus != 0 or y_plus != 0
      # Se a distância horizontal for a mais longínqua
      if x_plus.abs > y_plus.abs
        # Mudar direção para esquerda ou direita
        x_plus < 0 ? turn_left : turn_right
      # Se a distância vertical for a mais longínqua
      else
        # Mudar direção para cima ou baixo
        y_plus < 0 ? turn_up : turn_down
      end
    end
    # Calcular novas coordenadas
    new_x = @x + x_plus
    new_y = @y + y_plus
    # Se o valor a mais for (0,0) ou se o destino do pulo for passável
    if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y, 0)
      # Alinha posição
      straighten
      # Atualizar coordenadas
      @x = new_x
      @y = new_y
      # Calcular a distância
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      # Definir contador de pulo
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      # Limpar contador de parada
      @stop_count = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Olhar Abaixo
  #--------------------------------------------------------------------------
  
  def turn_down
    unless @direction_fix
      @direction = 2
      @stop_count = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Olhar à Direita
  #--------------------------------------------------------------------------
  
  def turn_left
    unless @direction_fix
      @direction = 4
      @stop_count = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Olhar à Esquerda
  #--------------------------------------------------------------------------
  
  def turn_right
    unless @direction_fix
      @direction = 6
      @stop_count = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Olhar Acima
  #--------------------------------------------------------------------------
  
  def turn_up
    unless @direction_fix
      @direction = 8
      @stop_count = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Girar 90° à Direita
  #--------------------------------------------------------------------------
  
  def turn_right_90
    case @direction
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end
  
  #--------------------------------------------------------------------------
  # Girar 90° à Esquerda
  #--------------------------------------------------------------------------
  
  def turn_left_90
    case @direction
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end
  
  #--------------------------------------------------------------------------
  # Girar 180°
  #--------------------------------------------------------------------------
  
  def turn_180
    case @direction
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end
  
  #--------------------------------------------------------------------------
  # Girar 90° Aleatório
  #--------------------------------------------------------------------------
  
  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end
  
  #--------------------------------------------------------------------------
  # Giro Aleatório
  #--------------------------------------------------------------------------
  
  def turn_random
    case rand(4)
    when 0
      turn_up
    when 1
      turn_right
    when 2
      turn_left
    when 3
      turn_down
    end
  end
  
  #--------------------------------------------------------------------------
  # Olhar para o Herói
  #--------------------------------------------------------------------------
  
  def turn_toward_player
    # Selecionar a diferença nas coordenadas do jogador
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Se as coordenadas forem iguais
    if sx == 0 and sy == 0
      return
    end
    # Se a distância horizontal for a mais longínqua
    if sx.abs > sy.abs
      # Olhar à esquerda ou direita na direção do Herói
      sx > 0 ? turn_left : turn_right
    # Se a distância vertical for a mais longínqua
    else
      # Olhar acima ou abaixo na direção do Herói
      sy > 0 ? turn_up : turn_down
    end
  end
  
  #--------------------------------------------------------------------------
  # Girar Herói (Contrário)
  #--------------------------------------------------------------------------
  
  def turn_away_from_player
    # Selecionar a diferença nas coordenadas do jogador
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Se as coordenadas forem iguais
    if sx == 0 and sy == 0
      return
    end
    # Se a distância horizontal for a mais longínqua
    if sx.abs > sy.abs
      # Olhar à esquerda ou direita na direção contária do Herói
      sx > 0 ? turn_right : turn_left
    # Se a distância vertical for a mais longínqua
    else
      # Olhar acima ou abaixo na direção contrária do Herói
      sy > 0 ? turn_down : turn_up
    end
  end
end
