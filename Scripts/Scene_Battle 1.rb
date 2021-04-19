#==============================================================================
# Scene_Battle (Parte 1)
#------------------------------------------------------------------------------
# Esta classe processa a tela de Batalha
#==============================================================================

class Scene_Battle
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Aqui cada tipo de dodos temporário de batalha é inicializado
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Inicializar o interpreter o evento de Batalha
    $game_system.battle_interpreter.setup(nil, 0)
    # Preparar Grupo de Inimigos
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # Criar janela de comandos dos Heróis
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Aqui todas as outras janelas são criadas
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # Criar o Spriteset
    @spriteset = Spriteset_Battle.new
    # Inicializar Espera
    @wait_count = 0
    # Executar transição
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # Iniciar a fase de pré-batalha
    start_phase1
    # Loop principal
    loop do
      # Atualizar tela de Jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualização do frame
      update
      # Aboratar o loop se a tela for alterada
      if $scene != self
        break
      end
    end
    # Atualizar Mapa
    $game_map.refresh
    # Preparar para transição
    Graphics.freeze
    # Exibição das janelas
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # Exibição do Spriteset
    @spriteset.dispose
    # Se estiver alternando para a tela de Título
    if $scene.is_a?(Scene_Title)
      # Transição de Tela
      Graphics.transition
      Graphics.freeze
    end
    # Se for um Teste de Batalha, alternar diretamente para a tela de Game Over
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # Determinar o Resultado de uma Batalha: Vitória ou Derrota
  #--------------------------------------------------------------------------
  
  def judge
    # Caso todos estejam mortos, ou o número de membros do Grupo for 0
    if $game_party.all_dead? or $game_party.actors.size == 0
      # E se for possível perder
      if $game_temp.battle_can_lose
        # Reproduzir BGM antes que a Batalha comece
        $game_system.bgm_play($game_temp.map_bgm)
        # Fim da Batalha
        battle_end(2)
        # Retornar
        return true
      end
      # Definir flag de Game Over
      $game_temp.gameover = true
      # Retornar
      return true
    end
    # Tornar o retorno falso se um inimigo exisir
    for enemy in $game_troop.enemies
      if enemy.exist?
        return false
      end
    end
    # Iniciar após a fase de Vitória da Batalha
    start_phase5
    # Return true
    return true
  end
  
  #--------------------------------------------------------------------------
  # Fim da Batalha
  #
  #     result : resultado (0=vitória, 1=derrota e 2=fuga)
  #--------------------------------------------------------------------------
  
  def battle_end(result)
    # Limpar flag de Batalha
    $game_temp.in_battle = false
    # Limpar flags de todas as ações dos Heróis
    $game_party.clear_actions
    # Remover os Status de Batalha
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    # Limpar Inimigos
    $game_troop.enemies.clear
    # Chamar Batalha ativa
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    # Alternar para a tela de Mapa
    $scene = Scene_Map.new
  end
  
  #--------------------------------------------------------------------------
  # Configuração do Evento de Batalha
  #--------------------------------------------------------------------------
  
  def setup_battle_event
    # Se o evento de Batalha estiver ocorrendo
    if $game_system.battle_interpreter.running?
      return
    end
    # Pesquisar todas as páginas do evento
    for index in 0...$data_troops[@troop_id].pages.size
      # Selecionar as páginas
      page = $data_troops[@troop_id].pages[index]
      # Tornar as condições de evento possíveis por refência com c
      c = page.condition
      # Ir para a próxima página se nenhuma condição for exigida
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      # Uma página é avançada se a ação foi completada
      if $game_temp.battle_event_flags[index]
        next
      end
      # Confirmar as condições de turno
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      # Confirmar as condições do Inimigo
      if c.enemy_valid
        enemy = $game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      # Confirmar as condições dos Heróis
      if c.actor_valid
        actor = $game_actors[c.actor_id]
        if actor == nil or actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      # Confirmar as condições de Switch
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      # Configurar evento
      $game_system.battle_interpreter.setup(page.list, 0)
      # Se a extensão desta página for uma Batalha ou Turno
      if page.span <= 1
        # Definir flag de ação completada
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # ISe o evento de Batalha estiver ocorrendo
    if $game_system.battle_interpreter.running?
      # Atualizar interpretador
      $game_system.battle_interpreter.update
      # Se houver uma ação forçada do Battler que não existe
      if $game_temp.forcing_battler == nil
        # Se o evento terminou de ocorrer
        unless $game_system.battle_interpreter.running?
          # Retornar as configurações de Batalha se a Batalha continuar
          unless judge
            setup_battle_event
          end
        end
        # Se não alcançou a fase de Batalha
        if @phase != 5
          # Atualizar a tela de Status
          @status_window.refresh
        end
      end
    end
    # Atualizar o System e a tela
    $game_system.update
    $game_screen.update
    # Se o Temporizador chegou a 0
    if $game_system.timer_working and $game_system.timer == 0
      # Abortar Batalha
      $game_temp.battle_abort = true
    end
    # Atualizar janelas
    @help_window.update
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    # Atualizar Spriteset
    @spriteset.update
    # Se uma transição estiver em processamento
    if $game_temp.transition_processing
      # Limpar flag de processamento de transição
      $game_temp.transition_processing = false
      # Executar transição
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # Se uma janela de mensagem estiver sendo exibida
    if $game_temp.message_window_showing
      return
    end
    # Se estiver exibindo um efito
    if @spriteset.effect?
      return
    end
    # Se acontecer o Game Over
    if $game_temp.gameover
      # Alternar para a tela de Game over
      $scene = Scene_Gameover.new
      return
    end
    # Se estiver retornando a tela de Título
    if $game_temp.to_title
      # Alternar para a tela de Título
      $scene = Scene_Title.new
      return
    end
    # Se a Batalha foi abortada
    if $game_temp.battle_abort
      # Reproduzir a BGM que tocava antes da Batalha iniciar
      $game_system.bgm_play($game_temp.map_bgm)
      # Fim da Batalha
      battle_end(1)
      return
    end
    # Se houver Espera
    if @wait_count > 0
      # Diminuir o contador de Espera
      @wait_count -= 1
      return
    end
    # Se houver uma ação forçada do Battler que não existe,
    # e o evento de Batalha estiver ocorrendo
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # Ramificação de acordo com a Fase
    case @phase
    when 1  # Pré-Batalha
      update_phase1
    when 2  # Comandos do Grupo de Heróis
      update_phase2
    when 3  # Comandos do Herói
      update_phase3
    when 4  # Principal
      update_phase4
    when 5  # Pós-Batalha
      update_phase5
    end
  end
end
