#==============================================================================
# Scene_Save
#------------------------------------------------------------------------------
# Esta classe processa o Save
#==============================================================================

class Scene_Save < Scene_File
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super("Em qual lugar você gostaria de salvar?")
  end
  
  #--------------------------------------------------------------------------
  # Processamento de Decisão
  #--------------------------------------------------------------------------
  
  def on_decision(filename)
    # Reproduzir Se de Save
    $game_system.se_play($data_system.save_se)
    # Graavar
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    # Caso tenha sido chamdo por um evento...
    if $game_temp.save_calling
      # Limpar flag de chamado de save
      $game_temp.save_calling = false
      # Mudar para a tela do Mapa
      $scene = Scene_Map.new
      return
    end
    # Mudar para a tela do Menu
    $scene = Scene_Menu.new(4)
  end
  
  #--------------------------------------------------------------------------
  # Processo de Cancelamento
  #--------------------------------------------------------------------------
  
  def on_cancel
    # Reproduzir SE de cancelamento
    $game_system.se_play($data_system.cancel_se)
    # Caso tenha sido chamdo por um evento...
    if $game_temp.save_calling
      # Limpar flag de chamado de save
      $game_temp.save_calling = false
      # Mudar para a tela do Mapa
      $scene = Scene_Map.new
      return
    end
    # Mudar para a tela do Menu
    $scene = Scene_Menu.new(4)
  end
  
  #--------------------------------------------------------------------------
  # Gravando
  #     file : Gravando um arquivo
  #--------------------------------------------------------------------------
  
  def write_save_data(file)
    # Criar desenho dos Heróis para salvar
    characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    # Gravar desenho dos Heróis para salvar
    Marshal.dump(characters, file)
    # Gravar contador de Tempo de Jogo
    Marshal.dump(Graphics.frame_count, file)
    # Acrescentar 1 em contador de saves
    $game_system.save_count += 1
    # Salvar número da Magia
    # Um número aleatório será selecionado cada vez que você salvar
    $game_system.magic_number = $data_system.magic_number
    # Gravar cada tipo de objeto do jogo
    Marshal.dump($game_system, file)
    Marshal.dump($game_switches, file)
    Marshal.dump($game_variables, file)
    Marshal.dump($game_self_switches, file)
    Marshal.dump($game_screen, file)
    Marshal.dump($game_actors, file)
    Marshal.dump($game_party, file)
    Marshal.dump($game_troop, file)
    Marshal.dump($game_map, file)
    Marshal.dump($game_player, file)
  end
end
