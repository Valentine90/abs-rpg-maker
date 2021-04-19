#==============================================================================
# Scene_Battle (Parte 4)
#------------------------------------------------------------------------------
# Esta classe processa a tela de Batalha
#==============================================================================

class Scene_Battle
  
  #--------------------------------------------------------------------------
  # Inicialização da Fase Principal
  #--------------------------------------------------------------------------
  
  def start_phase4
    # Alternar para a fase 4
    @phase = 4
    # Este é o contador de Turnos, a cada ação é adicionado 1
    $game_temp.battle_turn += 1
    # Aqui é feita uma procura por eventos de batalha
    for index in 0...$data_troops[@troop_id].pages.size
      # Selecionar a página de evento
      page = $data_troops[@troop_id].pages[index]
      # Se a extensão desta página for um Turno
      if page.span == 1
        # Limpar flag de ações completadas
        $game_temp.battle_event_flags[index] = false
      end
    end
    # Definir Herói como não selecionável
    @actor_index = -1
    @active_battler = nil
    # Habilitar janela de comandos do Grupo de Heróis
    @party_command_window.active = false
    @party_command_window.visible = false
    # Desabilitar janela de comandos do Herói
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Definir flag de fase Principal
    $game_temp.battle_main_phase = true
    # Criar as ações do Inimigo
    for enemy in $game_troop.enemies
      enemy.make_action
    end
    # Criar a ordem das ações
    make_action_orders
    # Alternar para o passo 1
    @phase4_step = 1
  end
  
  #--------------------------------------------------------------------------
  # Criar a Ordem das Ações
  #--------------------------------------------------------------------------
  
  def make_action_orders
    # Inicializar a ordem de batalha de @action_battlers
    @action_battlers = []
    # Adicionar os Inimigos para a ordem de batalha de @action_battlers
    for enemy in $game_troop.enemies
      @action_battlers.push(enemy)
    end
    # Adicionar os Heróis para a ordem de batalaha de @action_battlers
    for actor in $game_party.actors
      @action_battlers.push(actor)
    end
    # Aqui é determinada a velocidade de cada ação
    for battler in @action_battlers
      battler.make_action_speed
    end
    # Arranjar a ordem de batalha de acordo com a velocidade, da maior para a 
    # menor
    @action_battlers.sort! {|a,b|
      b.current_action.speed - a.current_action.speed }
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase Principal)
  #--------------------------------------------------------------------------
  
  def update_phase4
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Passo 1 da Fase Principal : Preparação das Ações)
  #--------------------------------------------------------------------------
  
  def update_phase4_step1
    # Ocultar a janela de Ajuda
    @help_window.visible = false
    # Determinar se houve vitória ou derrota
    if judge
      # Se houver vitória ou derrota, fim do método
      return
    end
    # Se não exister um Battler com ações pré-definidas
    if $game_temp.forcing_battler == nil
      # Configurar o evento de batalha
      setup_battle_event
      # Se o evento de batalha estiver ocorrendo
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # Se existir um Battler com ações pré-definidas
    if $game_temp.forcing_battler != nil
      # Adicionar ao cabeçalho dos inativos ou mover
      @action_battlers.delete($game_temp.forcing_battler)
      @action_battlers.unshift($game_temp.forcing_battler)
    end
    # Se todos os Battlers já tiverem feitos as suas ações
    if @action_battlers.size == 0
      # Iniciar a fase de comandos do Grupo de Heróis
      start_phase2
      return
    end
    # Inicializar o ID das animações e dos eventos comuns
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    # Alternar os Battlers do cabeçalho dos inativos
    @active_battler = @action_battlers.shift
    # Se já tiverem sido removidos da batalha
    if @active_battler.index == nil
      return
    end
    # Causar Dano
    if @active_battler.hp > 0 and @active_battler.slip_damage?
      @active_battler.slip_damage_effect
      @active_battler.damage_pop = true
    end
    # Aqui é imposta uma remoção automática para os status
    @active_battler.remove_states_auto
    # Então é feita uma atualização da janela dos status
    @status_window.refresh
    # Alternar para o passo 2
    @phase4_step = 2
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Passo 2 da Fase Principal : Início das Ações)
  #--------------------------------------------------------------------------
  
  def update_phase4_step2
    # Se não for uma ação pré-determinada
    unless @active_battler.current_action.forcing
      # Se forem aceitos apenas ataques normais tanto de Heróis como de Inimigos
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        # Definir o ataque como uma ação
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      # Se for aceita nenhuma ação
      if @active_battler.restriction == 4
        # Limpar Battler que estiver com uma ação pré-definida
        $game_temp.forcing_battler = nil
        # Alternar para a fase 1
        @phase4_step = 1
        return
      end
    end
    # Limpar os Battlers que forem alvo
    @target_battlers = []
    # Ramificação de acordo com cada ação
    case @active_battler.current_action.kind
    when 0  # Básico
      make_basic_action_result
    when 1  # Habilidade
      make_skill_action_result
    when 2  # Item
      make_item_action_result
    end
    # Alternar para o passo 3
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  
  #--------------------------------------------------------------------------
  # Criar o Resultado das Ações Básicas
  #--------------------------------------------------------------------------
  
  def make_basic_action_result
    # Caso seje um ataque
    if @active_battler.current_action.basic == 0
      # Definir o ID da animação
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      # Se o Battler que estiver atuando para um Inimigo
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # Se o Battler que estiver atuando para um Herói
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # Definir a ordem dos Battlers alvo
      @target_battlers = [target]
      # Aplicar os resultados de ataque normal
      for target in @target_battlers
        target.attack_effect(@active_battler)
      end
      return
    end
    # Se Defender
    if @active_battler.current_action.basic == 1
      # Exibir a palavra Defesa na janela de Ajuda
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    # Se Fugir
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # Exibir a palavra Escape na janela de Ajuda
      @help_window.set_text("Escape", 1)
      # Fugir
      @active_battler.escape
      return
    end
    # Se não fizer nada
    if @active_battler.current_action.basic == 3
      # Limpar o Battler que estiver com uma ação pré-definida
      $game_temp.forcing_battler = nil
      # Alternar para o passo 1
      @phase4_step = 1
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Definir o Battler Alvo para a Habilidade ou Item
  #     scope : Alcance do efeito da Habilidade ou Item
  #--------------------------------------------------------------------------
  
  def set_target_battlers(scope)
    # Se o Battler que estiver fazendo a ação for um Inimigo
    if @active_battler.is_a?(Game_Enemy)
      # Ramificação por alcance do efeito
      case scope
      when 1  # Apenas um Inimigo
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 2  # Todos os Inimigos
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 3  # Apenas um aliado
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4  # Todos os aliados
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 5  # Apenas um aliado morto (HP=0)
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          @target_battlers.push(enemy)
        end
      when 6  # Todos os aliados mortos (HP 0) 
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            @target_battlers.push(enemy)
          end
        end
      when 7  # Usuário
        @target_battlers.push(@active_battler)
      end
    end
    # Se o Battler que estiver fazendo a ação for um Herói
    if @active_battler.is_a?(Game_Actor)
      # Ramificação por alcance do efeito
      case scope
      when 1  # Apenas um Inimigo
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2  # Todos os Inimigos
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 3  # Apenas um aliado
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4  # Todos os aliados
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5  # Apenas um aliado morto (HP=0)
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6  # Todos os aliados mortos (HP 0)
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7  # Usuário
        @target_battlers.push(@active_battler)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Criação o Resultado das Habilidade
  #--------------------------------------------------------------------------
  
  def make_skill_action_result
    # Selecionar Habilidade
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # Se não for uma ação pré-definida
    unless @active_battler.current_action.forcing
      # Se for impossível utilizar porque não há MP suficiente
      unless @active_battler.skill_can_use?(@skill.id)
        # Limpar o Battler que estiver em uma ação pré-definida
        $game_temp.forcing_battler = nil
        # Alternar para o passo 1
        @phase4_step = 1
        return
      end
    end
    # Utilizar MP
    @active_battler.sp -= @skill.sp_cost
    # Atualizar a janela de Status
    @status_window.refresh
    # Exibir o nome da Habilidade na janela de Ajuda
    @help_window.set_text(@skill.name, 1)
    # Definir o ID da animação
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # Definir o ID do Evento Comum
    @common_event_id = @skill.common_event_id
    # Definir os Battlers alvo
    set_target_battlers(@skill.scope)
    # Aplicar os efeitos da Habilidade
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
  end
  
  #--------------------------------------------------------------------------
  # Criar o resultado dos Itens
  #--------------------------------------------------------------------------
  
  def make_item_action_result
    # Selecionar Item
    @item = $data_items[@active_battler.current_action.item_id]
    # Se for impossível utilizar porque não há mais destes Itens
    unless $game_party.item_can_use?(@item.id)
      # Alternar para o passo 1
      @phase4_step = 1
      return
    end
    # Se for consumível
    if @item.consumable
      # Diminui 1 item da quantidade total
      $game_party.lose_item(@item.id, 1)
    end
    # Exibir o nome do Item na tela de Ajuda
    @help_window.set_text(@item.name, 1)
    # Definir o ID da animação
    @animation1_id = @item.animation1_id
    @animation2_id = @item.animation2_id
    # Definir o ID do Evento Comum
    @common_event_id = @item.common_event_id
    # Decidir as ossibilidades de alvo
    index = @active_battler.current_action.target_index
    target = $game_party.smooth_target_actor(index)
    # Definir o alvo
    set_target_battlers(@item.scope)
    # Aplicar os efeitos do Item
    for target in @target_battlers
      target.item_effect(@item)
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Passo 3 da Fase Principal : Animação de Ataque)
  #--------------------------------------------------------------------------
  
  def update_phase4_step3
    # Animação de Ataque (caso o ID seje 0, exibir um flash branco)
    if @animation1_id == 0
      @active_battler.white_flash = true
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    # Alternar para o passo 4
    @phase4_step = 4
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Passo 4 da Fase Principal : Animação do Alvo)
  #--------------------------------------------------------------------------
  
  def update_phase4_step4
    # Animação do alvo
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Errou!")
    end
    # A animação tem pelo menos 8 frames, indiferentemente do seu comprimento
    @wait_count = 8
    # Alternar para o passo 5
    @phase4_step = 5
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Passo 5 da Fase Principal : Exibição do Dano)
  #--------------------------------------------------------------------------
  
  def update_phase4_step5
    # Esconder a janela de Ajuda
    @help_window.visible = false
    # Atualizar a janela de Status
    @status_window.refresh
    # Exibir dano
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = true
      end
    end
    # Alternar para o passo 6
    @phase4_step = 6
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Passo 6 da Fase Principal : Atualização)
  #--------------------------------------------------------------------------
  
  def update_phase4_step6
    # Limpar o Battler que estiver com uma ação pré-definida
    $game_temp.forcing_battler = nil
    # Se o ID do Evento Comum for válido
    if @common_event_id > 0
      # Configurar o evento
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    # Alternar para o passo 1
    @phase4_step = 1
  end
end
