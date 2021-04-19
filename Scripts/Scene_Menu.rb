#==============================================================================
# Scene_Menu
#------------------------------------------------------------------------------
# Esta classe processa a Tela de Menu
#==============================================================================

class Scene_Menu
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     menu_index : posição inicial do cursor de comando
  #--------------------------------------------------------------------------
  
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Criar janela de comando
    s1 = $data_system.words.item
    s2 = $data_system.words.skill
    s3 = $data_system.words.equip
    s4 = "Status"
    s5 = "Salvar"
    s6 = "Fim de Jogo"
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    # Se o número de membros do Grupo de Heróis for 0
    if $game_party.actors.size == 0
      # Desabilar as janelas de Item, Habilidades, Equipamento e Status
      @command_window.disable_item(0)
      @command_window.disable_item(1)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
    end
    # Se Salvar for Proibido
    if $game_system.save_disabled
      # Desabilitar Salvar
      @command_window.disable_item(4)
    end
    # Criar janela de Tempo de Jogo
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = 0
    @playtime_window.y = 224
    # Criar janela de Número Passos
    @steps_window = Window_Steps.new
    @steps_window.x = 0
    @steps_window.y = 320
    # Criar janela de Dinheiro
    @gold_window = Window_Gold.new
    @gold_window.x = 0
    @gold_window.y = 416
    # Criar janela de Status
    @status_window = Window_MenuStatus.new
    @status_window.x = 160
    @status_window.y = 0
    # Executar transição
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar a tela de jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualizar Frame
      update
      # Abortar loop se a tela for alterada
      if $scene != self
        break
      end
    end
    # Preparar para transiçõa
    Graphics.freeze
    # Exibição das janelas
    @command_window.dispose
    @playtime_window.dispose
    @steps_window.dispose
    @gold_window.dispose
    @status_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar janelas
    @command_window.update
    @playtime_window.update
    @steps_window.update
    @gold_window.update
    @status_window.update
    # Se a janela de comandos estiver ativo: chamar update_command
    if @command_window.active
      update_command
      return
    end
    # Se a janela de Status estiver ativa: call update_status
    if @status_window.active
      update_status
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela de Comandos estiver Ativa)
  #--------------------------------------------------------------------------
  
  def update_command
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Alternar para a tela do mapa
      $scene = Scene_Map.new
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Se o comando for outro senão Salvar, Fim de Jogo e o número de Heróis no
      # Grupo for 0
      if $game_party.actors.size == 0 and @command_window.index < 4
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Ramificação por posição do cursor na janela de comandos
      case @command_window.index
      when 0  # Itens
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Alternar para a tela de Itens
        $scene = Scene_Item.new
      when 1  # Habilidades
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Ativar o status da janela
        @command_window.active = false
        @status_window.active = true
        @status_window.index = 0
      when 2  # Equipamentos
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Ativar o status da janela
        @command_window.active = false
        @status_window.active = true
        @status_window.index = 0
      when 3  # Status
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Ativar o status da janela
        @command_window.active = false
        @status_window.active = true
        @status_window.index = 0
      when 4  # Salvar
        # Se Salvar for proibido
        if $game_system.save_disabled
          # Reproduzir SE de erro
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Alternar para a tela de save
        $scene = Scene_Save.new
      when 5  # Fim de Jogo
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Alternar para a tela de Fim de Jogo
        $scene = Scene_End.new
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando o status da Janela estiver Ativo)
  #--------------------------------------------------------------------------
  
  def update_status
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Torna a janela de comandos ativa
      @command_window.active = true
      @status_window.active = false
      @status_window.index = -1
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Ramificação por posição do cursor na janela de comandos
      case @command_window.index
      when 1  # Habilidades
        # Se o limite de ação deste Herói for de 2 ou mais
        if $game_party.actors[@status_window.index].restriction >= 2
          # Reproduzir SE de erro
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Alternar para a tela de Habilidades
        $scene = Scene_Skill.new(@status_window.index)
      when 2  # Equipamento
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Alternar para a tela de Equipamento
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # Status
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Alternar para a tela de Status
        $scene = Scene_Status.new(@status_window.index)
      end
      return
    end
  end
end
