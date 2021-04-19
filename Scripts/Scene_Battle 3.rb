#==============================================================================
# Scene_Battle (Parte 3)
#------------------------------------------------------------------------------
# Esta classe processa a tela de Batalha
#==============================================================================

class Scene_Battle
  
  #--------------------------------------------------------------------------
  # Inicialização da Fase de Comandos do Herói
  #--------------------------------------------------------------------------
  
  def start_phase3
    # Alternar para a fase 3
    @phase = 3
    # Definir Herói como não selecionável
    @actor_index = -1
    @active_battler = nil
    # Ir para a entrada de comandos do Próximo Herói
    phase3_next_actor
  end
  
  #--------------------------------------------------------------------------
  # Ir para a Entrada de Comandos do Próximo Herói
  #--------------------------------------------------------------------------
  
  def phase3_next_actor
    # Loop
    begin
      # Desligar o efeito de Brilho do Herói
      if @active_battler != nil
        @active_battler.blink = false
      end
      # Se for o último Herói
      if @actor_index == $game_party.actors.size-1
        # Iniciar fase Principal
        start_phase4
        return
      end
      # Avaçar o índice de Heróis
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # Mais uma vez se o Herói recusar a entrada de comandos
    end until @active_battler.inputable?
    # Configurar a janela de comandos do Herói
    phase3_setup_command_window
  end
  
  #--------------------------------------------------------------------------
  # Ir para a Entrada de Comandos do Herói Anterior
  #--------------------------------------------------------------------------
  
  def phase3_prior_actor
    # Loop
    begin
      # Desligar o efeito de Brilho do Herói
      if @active_battler != nil
        @active_battler.blink = false
      end
      # Se for o primeiro Herói
      if @actor_index == 0
        # Iniciar fase de comando do Grupo de Heróis
        start_phase2
        return
      end
      # Retornar para o índice de Heróis
      @actor_index -= 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # Mais uma vez se o Herói recusar a entrada de comandos
    end until @active_battler.inputable?
    # Configurar a janela de comandos do Herói
    phase3_setup_command_window
  end
  
  #--------------------------------------------------------------------------
  # Configuração da Janela de Comandos do Herói
  #--------------------------------------------------------------------------
  
  def phase3_setup_command_window
    # Desabilitar a janela de comandos do Grupo de Heróis
    @party_command_window.active = false
    @party_command_window.visible = false
    # habilitar a janela de comandos do Herói
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # Definir a posição da janela de comandos do Herói
    @actor_command_window.x = @actor_index * 160
    # Definir índice como 0
    @actor_command_window.index = 0
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Comandos do Herói)
  #--------------------------------------------------------------------------
  
  def update_phase3
    # Se o ponteiro de Inimigos estiver ativado
    if @enemy_arrow != nil
      update_phase3_enemy_select
    # Se o ponteiro de Heróis estiver ativado
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # Se a janela de Habilidades estiver ativa
    elsif @skill_window != nil
      update_phase3_skill_select
    # Se a janela de Itens estiver ativa
    elsif @item_window != nil
      update_phase3_item_select
    # Se a janela de comandos do Herói estiver ativa
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de comandos do Herói : Comandos Básicos)
  #--------------------------------------------------------------------------
  
  def update_phase3_basic_command
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de Cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Ir para a entrada de comandos do Herói anterior
      phase3_prior_actor
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Ramificação por posição do cursor na janela
      case @actor_command_window.index
      when 0  # Atacar
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Definir ação
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # Iniciar seleção do Inimigo
        start_enemy_select
      when 1  # Habilidade
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Definir ação
        @active_battler.current_action.kind = 1
        # Iniciar a seleção da Habilidade
        start_skill_select
      when 2  # Defender
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Definir ação
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        # Ir para a entrada de comandos do próximo Herói
        phase3_next_actor
      when 3  # Item
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Definir ação
        @active_battler.current_action.kind = 2
        # Iniciar a seleção do Item
        start_item_select
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Comandos do Herói : Seleção da Habilidade)
  #--------------------------------------------------------------------------
  
  def update_phase3_skill_select
    # Tornar a janela de Habilidades visível
    @skill_window.visible = true
    # Atualizar janela de Habilidades
    @skill_window.update
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de Cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Finializar selação da Habilidade
      end_skill_select
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Selecionar os dados escolhidos na janela de Habilidades
      @skill = @skill_window.skill
      # Se não puder ser utilizado
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        # Reproduzir SE de Erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Definir ação
      @active_battler.current_action.skill_id = @skill.id
      # Tornar a janela de Habilidade inivisível
      @skill_window.visible = false
      # Se o alvo do efeito for apenas um Inimigo
      if @skill.scope == 1
        # Iniciar a seleção do Inimigo
        start_enemy_select
      # Se o alvo do efeito for apenas um aliado
      elsif @skill.scope == 3 or @skill.scope == 5
        # Iniciar a seleçao do Herói
        start_actor_select
      # Se o alvo do efeito não for simples
      else
        # Finalizar a seleção da Habilidade
        end_skill_select
        # Ir para a entrada de comandos do próximo Herói
        phase3_next_actor
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Comandos do Herói : Seleção do Item)
  #--------------------------------------------------------------------------
  
  def update_phase3_item_select
    # Tornar a janela de Itens visível
    @item_window.visible = true
    # Atualizar a janela de Itens
    @item_window.update
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de Cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Finalizar a seleção do Item
      end_item_select
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Selecionar os dados escolhidos na janela de Habilidades
      @item = @item_window.item
      # Se não puder ser utilizado
      unless $game_party.item_can_use?(@item.id)
        # Reproduzir SE de Erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Definir ação
      @active_battler.current_action.item_id = @item.id
      # Tornar a janela de Itens inivisível
      @item_window.visible = false
      # Se o alvo do efeito for apenas um Inimigo
      if @item.scope == 1
        # Iniciar a seleção do Inimigo
        start_enemy_select
      # Se o alvo do efeito for apenas um aliado
      elsif @item.scope == 3 or @item.scope == 5
        # Iniciar a seleção do Herói
        start_actor_select
      # Se o alvo do efeito não for simples
      else
        # Finalizar a seleção do Item
        end_item_select
        # Ir para a entrada de comandos do próximo Herói
        phase3_next_actor
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Comandos do Herói : Seleção do Inimigo)
  #--------------------------------------------------------------------------
  
  def update_phase3_enemy_select
    # Atualizar o ponteiro de seleção do Inimigo
    @enemy_arrow.update
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE Cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Fim da seleção do Inimigo
      end_enemy_select
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Definir ação
      @active_battler.current_action.target_index = @enemy_arrow.index
      # Fim da seleção do Inimigo
      end_enemy_select
      # Se a janela de Habilidades estiver sendo exibida
      if @skill_window != nil
        # Fim da seleção da Habilidade
        end_skill_select
      end
      # Se a janela de Itens estiver sendo exibida
      if @item_window != nil
        # Fim da seleção do Item
        end_item_select
      end
      # Ir para a entrada de comandos do próximo Herói
      phase3_next_actor
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Fase de Comandos do Herói : Seleção do Herói)
  #--------------------------------------------------------------------------
  
  def update_phase3_actor_select
    # Atualizar o ponteiro de seleção do Herói
    @actor_arrow.update
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE Cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Fim da seleção do herói
      end_actor_select
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Definir ação
      @active_battler.current_action.target_index = @actor_arrow.index
      # Fim da seleção do Herói
      end_actor_select
      # Se a janela de Habilidades estiver sendo exibida
      if @skill_window != nil
        # Fim da seleção da Habilidade
        end_skill_select
      end
      # Se a janela de Itens estiver sendo exibida
      if @item_window != nil
        # Fim da seleção do Item
        end_item_select
      end
      # Ir para a entrada de comandos do próximo Herói
      phase3_next_actor
    end
  end
  
  #--------------------------------------------------------------------------
  # Inicialização da Seleção do Inimigo
  #--------------------------------------------------------------------------
  
  def start_enemy_select
    # Aqui o ponteiro de seleção do Inimigo é criado
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    # E é criada uma associação com a janela de Ajuda
    @enemy_arrow.help_window = @help_window
    # Desabilitar a janela de comandos do Herói
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # Fim da Seleção do Inimigo
  #--------------------------------------------------------------------------
  
  def end_enemy_select
    # Exibição do ponteiro de seleção do Inimigo
    @enemy_arrow.dispose
    @enemy_arrow = nil
    # Se o comando for Lutar
    if @actor_command_window.index == 0
      # Habilitar a janela de comandos do Herói
      @actor_command_window.active = true
      @actor_command_window.visible = true
      # Esconder a janela de Ajuda
      @help_window.visible = false
    end
  end
  
  #--------------------------------------------------------------------------
  # Inicialização da Seleção do Herói
  #--------------------------------------------------------------------------
  
  def start_actor_select
    # Aqui o ponteiro de seleção do Herói é criado
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    # E é criada uma associação com a janela de Ajuda
    @actor_arrow.help_window = @help_window
    # Desabilitar a janela de comandos do Herói
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # Fim da Seleção do Herói
  #--------------------------------------------------------------------------
  
  def end_actor_select
    # Exibição do ponteiro de seleção do Herói
    @actor_arrow.dispose
    @actor_arrow = nil
  end
  
  #--------------------------------------------------------------------------
  # Inicialização da Seleção da Habilidade
  #--------------------------------------------------------------------------
  
  def start_skill_select
    # Aqui é criada a janela das Habilidades
    @skill_window = Window_Skill.new(@active_battler)
    # E é criada uma associação com a janela de Ajuda
    @skill_window.help_window = @help_window
    # Desabilitar a janela de comandos do Herói
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # Fim da Seleção da Habilidade
  #--------------------------------------------------------------------------
  
  def end_skill_select
    # Exibição da janela de Habilidades
    @skill_window.dispose
    @skill_window = nil
    # Esconder a janela de Ajuda
    @help_window.visible = false
    # Habilitar a janela de comandos do Herói
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  
  #--------------------------------------------------------------------------
  # Inicialização da Seleção do Item
  #--------------------------------------------------------------------------
  
  def start_item_select
    # Aqui é criada a janela de Itens
    @item_window = Window_Item.new
    # E é criada uma associação com a janela de Ajuda
    @item_window.help_window = @help_window
    # Desabilitar a janela de comandos do Herói
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # Fim da Seleção do Item
  #--------------------------------------------------------------------------
  
  def end_item_select
    # Exibição da janela de Itens
    @item_window.dispose
    @item_window = nil
    # Esconder a janela de Ajuda
    @help_window.visible = false
    # Habilitar a janela de comandos do Herói
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
end
