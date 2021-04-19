#==============================================================================
# Scene_Skill
#------------------------------------------------------------------------------
# Esta classe processa a tela de Habilidades
#==============================================================================

class Scene_Skill
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     actor_index : Índice de Heróis
  #--------------------------------------------------------------------------
  
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Selecionar Herói
    @actor = $game_party.actors[@actor_index]
    # Criar janela de Ajuda, Status e Habilidades
    @help_window = Window_Help.new
    @status_window = Window_SkillStatus.new(@actor)
    @skill_window = Window_Skill.new(@actor)
    # Associar a janela de Ajuda
    @skill_window.help_window = @help_window
    # Criar janela alvo (definir como invisível / inativa)
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
    # Executar transição
    Graphics.transition
    # Loop Principal
    loop do
      # Atualizar tela de Jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualizar frame
      update
      # Abortoar loop se a tela for alterada
      if $scene != self
        break
      end
    end
    # Preparar para transição
    Graphics.freeze
    # Exibição das janelas
    @help_window.dispose
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar janelas
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    # Se a janela de Habilidades estiver ativa: chamar update_skill
    if @skill_window.active
      update_skill
      return
    end
    # Se a janela alvo estiver ativa: chamar update_target
    if @target_window.active
      update_target
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Qunado a janela de Habilidades estiver ativa)
  #--------------------------------------------------------------------------
  
  def update_skill
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Alternar para a tela de Menu
      $scene = Scene_Menu.new(1)
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Selecionar dados escolhidos na janela de Habilidades
      @skill = @skill_window.skill
      # Aqui é verificado se é possível utilizar a Habilidade
      if @skill == nil or not @actor.skill_can_use?(@skill.id)
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Se o efeito da Habilidade for um aliado
      if @skill.scope >= 3
        # Ativar janela alvo
        @skill_window.active = false
        @target_window.x = (@skill_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # Definir se o alcance é um aliado ou todo o grupo
        if @skill.scope == 4 || @skill.scope == 6
          @target_window.index = -1
        elsif @skill.scope == 7
          @target_window.index = @actor_index - 10
        else
          @target_window.index = 0
        end
      # Se o efeito for outro senão para um aliado
      else
        # Se o ID do evento comum for válido
        if @skill.common_event_id > 0
          # Chamar evento comum da reserva
          $game_temp.common_event_id = @skill.common_event_id
          # Reproduzir SE da Habilidade
          $game_system.se_play(@skill.menu_se)
          # Descontar MP
          @actor.sp -= @skill.sp_cost
          # Recriar cada conteúdo das janelas
          @status_window.refresh
          @skill_window.refresh
          @target_window.refresh
          # Alternar para a tela do Mapa
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
    # Se o botão R for pressionado
    if Input.trigger?(Input::R)
      # Reproduzir SE de cursor
      $game_system.se_play($data_system.cursor_se)
      # O comando leva ao próximo Herói
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # Alternar para uma tela de Habilidades diferente
      $scene = Scene_Skill.new(@actor_index)
      return
    end
    # Se o botão L for pressionado
    if Input.trigger?(Input::L)
      # Reproduzir SE de cursor
      $game_system.se_play($data_system.cursor_se)
      # O comando leva ao Herói anterior
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # Alternar para uma tela de Habilidades diferente
      $scene = Scene_Skill.new(@actor_index)
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela alvo estiver ativa)
  #--------------------------------------------------------------------------
  
  def update_target
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Apagar janela alvo
      @skill_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Aqui é verificada a quantidade de MP a ser usada, 
      # caso não seja suficiente
      unless @actor.skill_can_use?(@skill.id)
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Se o alvo for todos os aliados
      if @target_window.index == -1
        # Aplicar os efeitos da Habilidade em todo o Grupo de Heróis
        used = false
        for i in $game_party.actors
          used |= i.skill_effect(@actor, @skill)
        end
      end
      # Se o alvo for o usuário
      if @target_window.index <= -2
        # Aplicar os efeitos da Habilidade em si mesmo
        target = $game_party.actors[@target_window.index + 10]
        used = target.skill_effect(@actor, @skill)
      end
      # Se o alvo for um aliado
      if @target_window.index >= 0
        # Aplicar os efeitos da Habilidade no Herói alvo
        target = $game_party.actors[@target_window.index]
        used = target.skill_effect(@actor, @skill)
      end
      # Se a Habilidade for utilizada
      if used
        # Reproduzir SE da Habilidade
        $game_system.se_play(@skill.menu_se)
        # Descontar o MP
        @actor.sp -= @skill.sp_cost
        # Recriar o conteúdo de cada janela
        @status_window.refresh
        @skill_window.refresh
        @target_window.refresh
        # Se todo o Grupo de Heróis estiver morto
        if $game_party.all_dead?
          # Alternar para a tela de Game Over
          $scene = Scene_Gameover.new
          return
        end
        # Se o ID do evento comum for válido
        if @skill.common_event_id > 0
          # Chamar evento comum da reserva
          $game_temp.common_event_id = @skill.common_event_id
          # Alternar para a tela do Mapa
          $scene = Scene_Map.new
          return
        end
      end
      # Se a Habilidade não foi usada
      unless used
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
