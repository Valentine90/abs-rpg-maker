#==============================================================================
# Interpreter (Parte 5)
#------------------------------------------------------------------------------
# É a classe que interpreta os comandos de eventos do jogo.
# É usada dentro da classe Game_Event e Game_System.
#==============================================================================

class Interpreter
  
  #--------------------------------------------------------------------------
  # Teletransporte
  #--------------------------------------------------------------------------
  
  def command_201
    # Se estiver em batalha
    if $game_temp.in_battle
      # Continuar
      return true
    end
    # Se estiver teletrasportando, exibindo uma mensagem, ou processando uma 
    # transição
    if $game_temp.player_transferring or
       $game_temp.message_window_showing or
       $game_temp.transition_processing
      # Fim
      return false
    end
    # Definir flag de teletransporte
    $game_temp.player_transferring = true
    # Se o método de endereçamento for por apontamento
    if @parameters[0] == 0
      # Definir destino do Herói
      $game_temp.player_new_map_id = @parameters[1]
      $game_temp.player_new_x = @parameters[2]
      $game_temp.player_new_y = @parameters[3]
      $game_temp.player_new_direction = @parameters[4]
    # Se o método de endereçamento for por variáveis
    else
      # Definir destino do Herói
      $game_temp.player_new_map_id = $game_variables[@parameters[1]]
      $game_temp.player_new_x = $game_variables[@parameters[2]]
      $game_temp.player_new_y = $game_variables[@parameters[3]]
      $game_temp.player_new_direction = @parameters[4]
    end
    # Avançar índice
    @index += 1
    # Se Fade for definido
    if @parameters[5] == 0
      # Preparar para transição
      Graphics.freeze
      # Definir flag de teletransporte
      $game_temp.transition_processing = true
      $game_temp.transition_name = ""
    end
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Posição do Evento
  #--------------------------------------------------------------------------
  
  def command_202
    # Se estiver em batalha
    if $game_temp.in_battle
      # Continuar
      return true
    end
    # Selecionar Herói
    character = get_character(@parameters[0])
    # Se o Herói não existir
    if character == nil
      # Continuar
      return true
    end
    # Se o método de endereçamento for por apontamento
    if @parameters[1] == 0
      # Definir a posição do Herói
      character.moveto(@parameters[2], @parameters[3])
    # Se o método de endereçamento for por variáveis
    elsif @parameters[1] == 1
      # Definir a posição do Herói
      character.moveto($game_variables[@parameters[2]],
        $game_variables[@parameters[3]])
    # Se o método de endereçamento for por troca com outro evento
    else
      old_x = character.x
      old_y = character.y
      character2 = get_character(@parameters[2])
      if character2 != nil
        character.moveto(character2.x, character2.y)
        character2.moveto(old_x, old_y)
      end
    end
    # Definir a posição do Herói
    case @parameters[4]
    when 8  # Acima
      character.turn_up
    when 6  # Direita
      character.turn_right
    when 2  # Abaixo
      character.turn_down
    when 4  # Esquerda
      character.turn_left
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Movimento de Tela
  #--------------------------------------------------------------------------
  
  def command_203
    # Se estiver em batalha
    if $game_temp.in_battle
      # Continuar
      return true
    end
    # Se já estiver fazendo o scroll
    if $game_map.scrolling?
      # Fim
      return false
    end
    # Iniciar o scroll
    $game_map.start_scroll(@parameters[0], @parameters[1], @parameters[2])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opções do Mapa
  #--------------------------------------------------------------------------
  
  def command_204
    case @parameters[0]
    when 0  # Panorama
      $game_map.panorama_name = @parameters[1]
      $game_map.panorama_hue = @parameters[2]
    when 1  # Névoa
      $game_map.fog_name = @parameters[1]
      $game_map.fog_hue = @parameters[2]
      $game_map.fog_opacity = @parameters[3]
      $game_map.fog_blend_type = @parameters[4]
      $game_map.fog_zoom = @parameters[5]
      $game_map.fog_sx = @parameters[6]
      $game_map.fog_sy = @parameters[7]
    when 2  # Fundo de batalha
      $game_map.battleback_name = @parameters[1]
      $game_temp.battleback_name = @parameters[1]
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Tom da Névoa
  #--------------------------------------------------------------------------
  
  def command_205
    # Iniciar troca do tom de cor
    $game_map.start_fog_tone_change(@parameters[0], @parameters[1] * 2)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opacidade da Névoa
  #--------------------------------------------------------------------------
  
  def command_206
    # iniciar troca do nível de opacidade
    $game_map.start_fog_opacity_change(@parameters[0], @parameters[1] * 2)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mostrar Animação
  #--------------------------------------------------------------------------
  
  def command_207
    # Selecionar Herói
    character = get_character(@parameters[0])
    # Se o Herói não existir
    if character == nil
      # Continuar
      return true
    end
    # Definir o ID da animação
    character.animation_id = @parameters[1]
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Transparência
  #--------------------------------------------------------------------------
  
  def command_208
    # Mudar a transparência do Herói
    $game_player.transparent = (@parameters[0] == 0)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mover Evento
  #--------------------------------------------------------------------------
  
  def command_209
    # Selecionar Herói
    character = get_character(@parameters[0])
    # Se o Herói nã existir
    if character == nil
      # Continuar
      return true
    end
    # Executar a rota pré-definida
    character.force_move_route(@parameters[1])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Esperar Fim do Movimento
  #--------------------------------------------------------------------------
  
  def command_210
    # Se não estiver em batalha
    unless $game_temp.in_battle
      # Definir flag de fim de movimento
      @move_route_waiting = true
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Preparar Transição
  #--------------------------------------------------------------------------
  
  def command_221
    # Se estiver exibindo uma mensagem
    if $game_temp.message_window_showing
      # Fim
      return false
    end
    # Prepara para transição
    Graphics.freeze
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Executar Transição
  #--------------------------------------------------------------------------
  
  def command_222
    # Se já estiver ocorrendo uma transição
    if $game_temp.transition_processing
      # Fim
      return false
    end
    # Definir flag de transição
    $game_temp.transition_processing = true
    $game_temp.transition_name = @parameters[0]
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Cor da Tela
  #--------------------------------------------------------------------------
  
  def command_223
    # Iniciar troca de cor da tela
    $game_screen.start_tone_change(@parameters[0], @parameters[1] * 2)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Efeito Flash
  #--------------------------------------------------------------------------
  
  def command_224
    # Iniciar flash
    $game_screen.start_flash(@parameters[0], @parameters[1] * 2)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Efeito Tremor
  #--------------------------------------------------------------------------
  
  def command_225
    # Iniciar tremor
    $game_screen.start_shake(@parameters[0], @parameters[1],
      @parameters[2] * 2)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mostrar Imagem
  #--------------------------------------------------------------------------
  
  def command_231
    # Selecionar o número da imagem
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Se o método de endereçamento for por apontamento
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # Se o método de endereçamento for por variáveis
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # Exibir imagem
    $game_screen.pictures[number].show(@parameters[1], @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mover Imagem
  #--------------------------------------------------------------------------
  
  def command_232
    # Selecionar o número da imagem
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Se o método de endereçamento for por apontamento
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # Se o método de endereçamento for por variáveis
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # Mover imagem
    $game_screen.pictures[number].move(@parameters[1] * 2, @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Girar Imagem
  #--------------------------------------------------------------------------
  
  def command_233
    # Selecionar o número da imagem
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Selecionar a velocidade de rotação
    $game_screen.pictures[number].rotate(@parameters[1])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Tonalidade da Imagem
  #--------------------------------------------------------------------------
  
  def command_234
    # Selecionar o número da imagem
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Iniciar troca de tonalidade da imagem
    $game_screen.pictures[number].start_tone_change(@parameters[1],
      @parameters[2] * 2)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Deletar Imagem
  #--------------------------------------------------------------------------
  
  def command_235
    # Selecionar o número da imagem
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # Deletar imagem
    $game_screen.pictures[number].erase
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opções de Clima
  #--------------------------------------------------------------------------
  
  def command_236
    # Definir as opções de clima
    $game_screen.weather(@parameters[0], @parameters[1], @parameters[2])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Reproduzir BGM
  #--------------------------------------------------------------------------
  
  def command_241
    # Reproduzir BGM
    $game_system.bgm_play(@parameters[0])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Parar BGM
  #--------------------------------------------------------------------------
  
  def command_242
    # Parar BGM
    $game_system.bgm_fade(@parameters[0])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Reproduzir BGS
  #--------------------------------------------------------------------------
  
  def command_245
    # Reproduzir BGS
    $game_system.bgs_play(@parameters[0])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Parar BGS
  #--------------------------------------------------------------------------
  
  def command_246
    # Parar BGS
    $game_system.bgs_fade(@parameters[0])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Memorizar BGM/BGS
  #--------------------------------------------------------------------------
  
  def command_247
    # Memorizar BGM/BGS
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Reproduzir Memorizadas
  #--------------------------------------------------------------------------
  
  def command_248
    # Reproduzir memorizadas
    $game_system.bgm_restore
    $game_system.bgs_restore
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Reproduzir ME
  #--------------------------------------------------------------------------
  
  def command_249
    # Reproduzir ME
    $game_system.me_play(@parameters[0])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Reproduzir SE
  #--------------------------------------------------------------------------
  
  def command_250
    # Reproduzir SE
    $game_system.se_play(@parameters[0])
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Parar SE
  #--------------------------------------------------------------------------
  
  def command_251
    # Parar SE
    Audio.se_stop
    # Continuar
    return true
  end
end
