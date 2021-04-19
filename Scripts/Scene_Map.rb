#==============================================================================
# Scene_Map
#------------------------------------------------------------------------------
# Esta classe processa a tela de Mapa
#==============================================================================

class Scene_Map
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Criar o Spriteset
    @spriteset = Spriteset_Map.new
    # Criar as janelas de mensagem
    @message_window = Window_Message.new
    # Fazer transições
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar tela de jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualizar Frame
      update
      # Abortar loop se a tela foi alterada
      if $scene != self
        break
      end
    end
    # Preparar para transição
    Graphics.freeze
    # Exibição do Spriteset
    @spriteset.dispose
    # Exibição da janela de mensagem
    @message_window.dispose
    # Se estiver alternando para a tela de Título
    if $scene.is_a?(Scene_Title)
      # Desmaecer tela
      Graphics.transition
      Graphics.freeze
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Loop
    loop do
      # Atualizar Mapa, Interpretador e Jogador
      # (Esta ordenação de atualização é importante para quando as condições 
      # estiverem cheias para executar qualquer evento e o jogador não tem a 
      # oportunidade de se mover em algum instante)
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      # Atualizar tela de sistema
      $game_system.update
      $game_screen.update
      # Abortar o loop se o jogador não estiver se movendo
      unless $game_temp.player_transferring
        break
      end
      # Executar movimento
      transfer_player
      # Abortar loop se estiver ocorrendo um transição
      if $game_temp.transition_processing
        break
      end
    end
    # Atualizar Spriteset
    @spriteset.update
    # Atualizar janela de mensagens
    @message_window.update
    # Se ocorrer um Game Over
    if $game_temp.gameover
      # Alternar para a tela de Game Over
      $scene = Scene_Gameover.new
      return
    end
    # Se estiver retornando à tela de Título
    if $game_temp.to_title
      # Alternar para a tela de Título
      $scene = Scene_Title.new
      return
    end
    # Abortar loop se estiver ocorrendo um transição
    if $game_temp.transition_processing
      # Limpar flag de transição
      $game_temp.transition_processing = false
      # Executar transição
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # Se estiver exibindo uma mensagem
    if $game_temp.message_window_showing
      return
    end
    # Se a lista de encontros não estiver vazia, e o contador de encontro for 0
    if $game_player.encounter_count == 0 and $game_map.encounter_list != []
      # Se estiver ocorrendo um evento ou o encontro não for proibido
      unless $game_system.map_interpreter.running? or
             $game_system.encounter_disabled
        # Confirmar loop
        n = rand($game_map.encounter_list.size)
        troop_id = $game_map.encounter_list[n]
        # Se o Grupo de Inimigos não for inválido
        if $data_troops[troop_id] != nil
          # Definir flag de chamada de batalha
          $game_temp.battle_calling = true
          $game_temp.battle_troop_id = troop_id
          $game_temp.battle_can_escape = true
          $game_temp.battle_can_lose = false
          $game_temp.battle_proc = nil
        end
      end
    end
    # Se o boão B for pressionado
    if Input.trigger?(Input::B)
      # Se estiver ocorrendo um evento ou o menu não for proibido
      unless $game_system.map_interpreter.running? or
             $game_system.menu_disabled
        # Definir flag de chamda de Menu ou de Beep
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    # Se o Modo de Depuração estiver ativo ou a tecla F9 for pressionado
    if $DEBUG and Input.press?(Input::F9)
      # Definir flag de chamda de depuração
      $game_temp.debug_calling = true
    end
    # Se o jogador não estiver se movendo
    unless $game_player.moving?
      # Executar a chamada de cada tela
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Inserir Batalha
  #--------------------------------------------------------------------------
  
  def call_battle
    # Limpar flag de chamada de batalha
    $game_temp.battle_calling = false
    # Limpar flag de chamda de menu
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # Criar um contador de encontros
    $game_player.make_encounter_count
    # Memmorizar a BGM do mapa e parar a BGM
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    # Reproduzir SE de Batalha
    $game_system.se_play($data_system.battle_start_se)
    # Reproduzir BGM de Batalha
    $game_system.bgm_play($game_system.battle_bgm)
    # Alinhar a posição do Jogador
    $game_player.straighten
    # Alternar para a tela de Batalha
    $scene = Scene_Battle.new
  end
  
  #--------------------------------------------------------------------------
  # Inserir Loja
  #--------------------------------------------------------------------------
  
  def call_shop
    # Limpar flag de chamada de Loja
    $game_temp.shop_calling = false
    # Alinhar a posição do Jogador
    $game_player.straighten
    # Alternar para a tela de Loja
    $scene = Scene_Shop.new
  end
  
  #--------------------------------------------------------------------------
  # Inserir Nome do Herói
  #--------------------------------------------------------------------------
  
  def call_name
    # Limpar flag de entrar nome do Herói
    $game_temp.name_calling = false
    # Alinhar a posição do Jogador
    $game_player.straighten
    # Alternar para a tela de entrar nome do Herói
    $scene = Scene_Name.new
  end
  
  #--------------------------------------------------------------------------
  # Chamar Menu
  #--------------------------------------------------------------------------
  
  def call_menu
    # Limpar flag de chamada de Menu
    $game_temp.menu_calling = false
    # Se a flag de Beep estiver definida
    if $game_temp.menu_beep
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Limpar flag de Beep
      $game_temp.menu_beep = false
    end
    # Alinhar a posição do Jogador
    $game_player.straighten
    # Alternar para a tela de Menu
    $scene = Scene_Menu.new
  end
  
  #--------------------------------------------------------------------------
  # Chamar Menu de Save
  #--------------------------------------------------------------------------
  
  def call_save
    # Alinhar a posição do Jogador
    $game_player.straighten
    # Alternar para a tela de Save
    $scene = Scene_Save.new
  end
  
  #--------------------------------------------------------------------------
  # Chamar Depurador (Debug)
  #--------------------------------------------------------------------------
  
  def call_debug
    # Limpar flag de depurador
    $game_temp.debug_calling = false
    # Reproduzir SE de OK
    $game_system.se_play($data_system.decision_se)
    # Alinhar a posição do jogador
    $game_player.straighten
    # Alternar para a tela de Depuração
    $scene = Scene_Debug.new
  end
  
  #--------------------------------------------------------------------------
  # Teletransporte
  #--------------------------------------------------------------------------
  
  def transfer_player
    # Limpar flag de teletransporte
    $game_temp.player_transferring = false
    # Se o destino for para outro mapa
    if $game_map.map_id != $game_temp.player_new_map_id
      # Definir o novo mapa
      $game_map.setup($game_temp.player_new_map_id)
    end
    # Definir o destino de Jogador
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    # Definir a direção
    case $game_temp.player_new_direction
    when 2  # Abaixo
      $game_player.turn_down
    when 4  # Esquerda
      $game_player.turn_left
    when 6  # Direita
      $game_player.turn_right
    when 8  # Acima
      $game_player.turn_up
    end
    # Alinhar a posição do Jogador
    $game_player.straighten
    # Atualizar mapa (executar eventos de Processo Paralelo)
    $game_map.update
    # Recriar o Spriteset
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
    # Se estiver processando uma transição
    if $game_temp.transition_processing
      # Limpar flag de transição
      $game_temp.transition_processing = false
      # Executar transição
      Graphics.transition(20)
    end
    # Executar as definições do mapa como BGM e BGS
    $game_map.autoplay
    # Aqui os frames são resetados
    Graphics.frame_reset
    # Atualizar a entrada de informações
    Input.update
  end
end
