#==============================================================================
# Interpreter (Parte 7)
#------------------------------------------------------------------------------
# É a classe que interpreta os comandos de eventos do jogo.
# É usada dentro da classe Game_Event e Game_System.
#==============================================================================

class Interpreter
  
  #--------------------------------------------------------------------------
  # Mudar HP do Inimigo
  #--------------------------------------------------------------------------
  
  def command_331
    # Selcionar valor
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Processo com iterador
    iterate_enemy(@parameters[0]) do |enemy|
      # Se o HP não for 0
      if enemy.hp > 0
        # Mudar HP (Se não for permitido morrer tornar o HP=1)
        if @parameters[4] == false and enemy.hp + value <= 0
          enemy.hp = 1
        else
          enemy.hp += value
        end
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar MP do Inimigo
  #--------------------------------------------------------------------------
  
  def command_332
    # Selecionar valor
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Processo com iterador
    iterate_enemy(@parameters[0]) do |enemy|
      # Mudar MP
      enemy.sp += value
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Status do Inimigo
  #--------------------------------------------------------------------------
  
  def command_333
    # Processo com iterador
    iterate_enemy(@parameters[0]) do |enemy|
      # Se, considerando o HP 0, a opção de estado for válida
      if $data_states[@parameters[2]].zero_hp
        # Limpar flag de imortalidade
        enemy.immortal = false
      end
      # Mudar
      if @parameters[1] == 0
        enemy.add_state(@parameters[2])
      else
        enemy.remove_state(@parameters[2])
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Curar Inimigo
  #--------------------------------------------------------------------------
  
  def command_334
    # Processo com iterador
    iterate_enemy(@parameters[0]) do |enemy|
      # Curar tudo
      enemy.recover_all
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Aparição Inimiga
  #--------------------------------------------------------------------------
  
  def command_335
    # Selecionar Inimigo
    enemy = $game_troop.enemies[@parameters[0]]
    # Limpar flag de escondido
    if enemy != nil
      enemy.hidden = false
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Transformação Inimiga
  #--------------------------------------------------------------------------
  
  def command_336
    # selecionar inimigo
    enemy = $game_troop.enemies[@parameters[0]]
    # Processo de transformação
    if enemy != nil
      enemy.transform(@parameters[1])
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mostrar Animiação
  #--------------------------------------------------------------------------
  
  def command_337
    # Processo com iterador
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # Se o  existir
      if battler.exist?
        # Definir ID da animação
        battler.animation_id = @parameters[2]
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Receber Ação
  #--------------------------------------------------------------------------
  
  def command_338
    # Selecionar valor
    value = operate_value(0, @parameters[2], @parameters[3])
    # Processo com iterador
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # Se o battler existir
      if battler.exist?
        # Mudar HP
        battler.hp -= value
        # Se estiver em batalha
        if $game_temp.in_battle
          # Definir dano
          battler.damage = value
          battler.damage_pop = true
        end
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Forçar Ação
  #--------------------------------------------------------------------------
  
  def command_339
    # Ignorar se não estiver em batalha
    unless $game_temp.in_battle
      return true
    end
    # Ignorar se o número de turnos for 0
    if $game_temp.battle_turn == 0
      return true
    end
    # Processo com iterador (por conveniência, este processo não se repetirá)
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # Se o Battler existir
      if battler.exist?
        # Definir ação
        battler.current_action.kind = @parameters[2]
        if battler.current_action.kind == 0
          battler.current_action.basic = @parameters[3]
        else
          battler.current_action.skill_id = @parameters[3]
        end
        # Definir alvo da ação
        if @parameters[4] == -2
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_last_target_for_enemy
          else
            battler.current_action.decide_last_target_for_actor
          end
        elsif @parameters[4] == -1
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_random_target_for_enemy
          else
            battler.current_action.decide_random_target_for_actor
          end
        elsif @parameters[4] >= 0
          battler.current_action.target_index = @parameters[4]
        end
        # Definir flag de forçar ação
        battler.current_action.forcing = true
        # Se a açõ for válida e estiver ocorrendo agora
        if battler.current_action.valid? and @parameters[5] == 1
          # Definir a existência do battler na ação forçada
          $game_temp.forcing_battler = battler
          # Avançar índice
          @index += 1
          # Fim
          return false
        end
      end
    end
    # Continue
    return true
  end
  
  #--------------------------------------------------------------------------
  # Parar Batalha
  #--------------------------------------------------------------------------
  
  def command_340
    # Definir flag de Parar batalha
    $game_temp.battle_abort = true
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Chamar Menu
  #--------------------------------------------------------------------------
  
  def command_351
    # Definir flag de Parar batalha
    $game_temp.battle_abort = true
    # Definir flag de chamada de menu
    $game_temp.menu_calling = true
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Chamar Menu de Save
  #--------------------------------------------------------------------------
  
  def command_352
    # Definir flag de Parar batalha
    $game_temp.battle_abort = true
    # Definir flag de chamada de save
    $game_temp.save_calling = true
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Game Over
  #--------------------------------------------------------------------------
  
  def command_353
    # Definir flag de Game Over
    $game_temp.gameover = true
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Voltar à Tela de Título
  #--------------------------------------------------------------------------
  
  def command_354
    # Definir flag de voltar à tela de título
    $game_temp.to_title = true
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Chamar Script
  #--------------------------------------------------------------------------
  
  def command_355
    # Definir preimeira linha para o script
    script = @list[@index].parameters[0] + "\n"
    # Loop
    loop do
      # Se o próximo comando de evento estiver na segunda linha ou depois
      if @list[@index+1].code == 655
        # Adicionar a segunda ou linha ou depois para o script
        script += @list[@index+1].parameters[0] + "\n"
      # Se o próximo comando de evento não estiver na segunda linha ou depois
      else
        # Loop de parada
        break
      end
      # Avançar índice
      @index += 1
    end
    # Avaliação
    result = eval(script)
    # Se o valor retornado for falsp
    if result == false
      # Fim
      return false
    end
    # Continuar
    return true
  end
end
