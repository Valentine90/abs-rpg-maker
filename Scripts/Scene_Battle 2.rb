#==============================================================================
# Scene_Battle (Parte 2)
#------------------------------------------------------------------------------
# Esta classe processa a tela de Batalha
#==============================================================================

class Scene_Battle
  
  #--------------------------------------------------------------------------
  # Inicialização da Fase de Pré-Batalha
  #--------------------------------------------------------------------------
  
  def start_phase1
    # Alternar para a fase 1
    @phase = 1
    # Limpar todas as ações dos membros do Grupo de Heróis
    $game_party.clear_actions
    # Configurar evento de batalha
    setup_battle_event
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Pré-Batalha)
  #--------------------------------------------------------------------------
  
  def update_phase1
    # Aqui é determinado se houve vitória ou derrota
    if judge
      # Se houver vitória ou derrota: fim do método
      return
    end
    # Iniciar fase de comandos do Grupo de Heróis
    start_phase2
  end
  
  #--------------------------------------------------------------------------
  # Inicializar Fase de Comandos do Grupo de Heróis
  #--------------------------------------------------------------------------
  
  def start_phase2
    # Alternar para a fase 2
    @phase = 2
    # Definir Heróis para não selecionáveis
    @actor_index = -1
    @active_battler = nil
    # Habilitar janela de comandos do Grupo de Heróis
    @party_command_window.active = true
    @party_command_window.visible = true
    # Desabilitar janela de comandos do Grupo de Heróis
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Limpar flag de fase Principal
    $game_temp.battle_main_phase = false
    # Limpar todas as ações de membros do Grupo de Heróis
    $game_party.clear_actions
    # Se for impossível a entrada do comando
    unless $game_party.inputable?
      # Iniciar fase Principal
      start_phase4
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do frame (Fase de Comandos do Grupo de Heróis)
  #--------------------------------------------------------------------------
  
  def update_phase2
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Ramificação por posição do cursor na janela
      case @party_command_window.index
      when 0  # Lutar
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Iniciar fase de comandos do Grupo de Heróis
        start_phase3
      when 1  # Fugir
        # Se não for possivel escapar
        if $game_temp.battle_can_escape == false
          # Reproduzir SE de Erro
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Processamento da fuga
        update_phase2_escape
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Comandos do Grupo de Heróis: Fuga)
  #--------------------------------------------------------------------------
  
  def update_phase2_escape
    # Calcular a agilidade média dos Inimigos
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # Calacular a agilidade média dos Heróis
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # Calcular o sucesso da fuga
    success = rand(100) < 50 * actors_agi / enemies_agi
    # Se a fuga for bem sucedida
    if success
      # Reproduzir SE de Fuga
      $game_system.se_play($data_system.escape_se)
      # Retornar para BGM de antes da Batalha ser iniciada
      $game_system.bgm_play($game_temp.map_bgm)
      # Fim da Batalha
      battle_end(1)
    # Se a fuga falhou
    else
      # Limpar todas as ações dos membros do Grupo de Heróis
      $game_party.clear_actions
      # Iniciar fase Princiapal
      start_phase4
    end
  end
  
  #--------------------------------------------------------------------------
  # Inicialização Fase de Pós-Batalha
  #--------------------------------------------------------------------------
  
  def start_phase5
    # Alternar para a fase 5
    @phase = 5
    # Reproduzir ME de fim de Batalha
    $game_system.me_play($game_system.battle_end_me)
    # Retornar para BGM de antes da Batalha ser iniciada
    $game_system.bgm_play($game_temp.map_bgm)
    # Inicializar EXP, quantidade de dinheiro e tesouros
    exp = 0
    gold = 0
    treasures = []
    # Loop
    for enemy in $game_troop.enemies
      # Se o Inimigo não estiver escondido
      unless enemy.hidden
        # Adicionar a EXP e a quantidade de dinheiro obtidos
        exp += enemy.exp
        gold += enemy.gold
        # Determinar se aparece algum tesouro
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          if enemy.weapon_id > 0
            treasures.push($data_weapons[enemy.weapon_id])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[enemy.armor_id])
          end
        end
      end
    end
    # o Limite de tesouros é de 6 Itens
    treasures = treasures[0..5]
    # Obtendo a EXP
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
        end
      end
    end
    # Obtendo o dinheiro
    $game_party.gain_gold(gold)
    # Obtendo os tesouros
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
    # Criar janela de resultado de Batalha
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    # Definir Espera
    @phase5_wait_count = 100
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Pós-Batalha)
  #--------------------------------------------------------------------------
  
  def update_phase5
    # Se a Espera for maior do que 0
    if @phase5_wait_count > 0
      # Diminuir a Espera
      @phase5_wait_count -= 1
      # Se a Espera chegar a 0
      if @phase5_wait_count == 0
        # Exibir o resultado da Batalha
        @result_window.visible = true
        # Limpar flag de fase Principal
        $game_temp.battle_main_phase = false
        # Atualizar janela de Status
        @status_window.refresh
      end
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Fim da Batalha
      battle_end(0)
    end
  end
end
