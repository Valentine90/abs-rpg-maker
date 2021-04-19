#==============================================================================
# Scene_Title
#------------------------------------------------------------------------------
# Esta classe trata da Tela de Título
#==============================================================================

class Scene_Title
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Se estiver em Teste de Batalha
    if $BTEST
      battle_test
      return
    end
    # Carregar o Banco de Dados
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # Criar um Sistema
    $game_system = Game_System.new
    # Criar um gráfico de título
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # Criar uma janela de comandos
    s1 = "Novo Jogo"
    s2 = "Continuar"
    s3 = "Sair"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    # O comando Continuar (s2) tem uma determinante
    # Aqui é checado se existe algum arquivo de save
    # Se estiver habilitado, tornar @continue_enabled verdadeiro; se estiver 
    # desabilitado, tornar falso
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    # Se Continuar estiver habilitado, mover o cursor para "Continuar"
    # Se estiver desabilitado, o texto será mostrado em cinza
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # Reproduzir BGM de Título
    $game_system.bgm_play($data_system.title_bgm)
    # Parar de reproduzir BGS e ME
    Audio.me_stop
    Audio.bgs_stop
    # Executar transição
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar a tela de jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualizar o frame
      update
      # Abortar o loop caso a tela tenha sido alterada
      if $scene != self
        break
      end
    end
    # Preparar para transição
    Graphics.freeze
    # Exibir a janela de comandos
    @command_window.dispose
    # Exibir o gráfico de Título
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar a janela de comandos
    @command_window.update
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # ramificação pela posição do cursor
      case @command_window.index
      when 0  # Novo Jogo
        command_new_game
      when 1  # Continuar
        command_continue
      when 2  # Sair
        command_shutdown
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Comando: Novo Jogo
  #--------------------------------------------------------------------------
  
  def command_new_game
    # Reproduzir SE de OK
    $game_system.se_play($data_system.decision_se)
    # Parar BGM
    Audio.bgm_stop
    # Aqui o contador de frames é resetado para que se conte o Tempo de Jogo
    Graphics.frame_count = 0
    # Criar cada tipo de objetos do jogo
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # Configurar Grupo Inicial
    $game_party.setup_starting_members
    # Configurar posição inicial no mapa
    $game_map.setup($data_system.start_map_id)
    # Aqui o Jogador é movido até a posição inical configurada
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # Atualizar Jogador
    $game_player.refresh
    # Rodar, de acordo com o mapa, a BGM e a BGS
    $game_map.autoplay
    # Atualizar mapa (executar processos paralelos)
    $game_map.update
    # Mudar para a tela do mapa
    $scene = Scene_Map.new
  end
  
  #--------------------------------------------------------------------------
  # Comando: Continuar
  #--------------------------------------------------------------------------
  
  def command_continue
    # Se Continuar estiver desabilitado
    unless @continue_enabled
      # Reproduzir SE de erro
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Reproduzir SE de OK
    $game_system.se_play($data_system.decision_se)
    # Mudar para a tela de Carregar arquivos
    $scene = Scene_Load.new
  end
  
  #--------------------------------------------------------------------------
  # Comando: Sair
  #--------------------------------------------------------------------------
  
  def command_shutdown
    # Reproduzir SE de OK
    $game_system.se_play($data_system.decision_se)
    # Diminuir o volume de BGM, BGS e ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # Sair
    $scene = nil
  end
  
  #--------------------------------------------------------------------------
  # Teste de Batalha
  #--------------------------------------------------------------------------
  
  def battle_test
    # Carregar Banco de Dados para o Teste de Batalha
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # Aqui o contador de frames é resetado para que se conte o Tempo de Jogo
    Graphics.frame_count = 0
    # Criar cada tipo de objetos do jogo
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # Configurar Grupo para o Teste de Batalha
    $game_party.setup_battle_test_members
    # Definir o ID do Grupo de Inimigos, a possibilidade de fuga e o Fundo de 
    # Batalha
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # Reproduzri SE de início de batalha
    $game_system.se_play($data_system.battle_start_se)
    # Reproduzir BGM de batalha
    $game_system.bgm_play($game_system.battle_bgm)
    # Mudar para a tela de batalha
    $scene = Scene_Battle.new
  end
end
