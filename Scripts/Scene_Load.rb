#==============================================================================
# Scene_Load
#------------------------------------------------------------------------------
# Esta classe processa a tela de Continuar
#==============================================================================

class Scene_Load < Scene_File
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    # Recriar objetos temporários
    $game_temp = Game_Temp.new
    # Timestamp (inserção de tempo)
    $game_temp.last_file_index = 0
    latest_time = Time.at(0)
    for i in 0..3
      filename = make_filename(i)
      if FileTest.exist?(filename)
        file = File.open(filename, "r")
        if file.mtime > latest_time
          latest_time = file.mtime
          $game_temp.last_file_index = i
        end
        file.close
      end
    end
    super("Qual jogo você deseja carregar?")
  end
  
  #--------------------------------------------------------------------------
  # Processando a Decisão
  #--------------------------------------------------------------------------
  
  def on_decision(filename)
    # Se o arquivo não existir
    unless FileTest.exist?(filename)
      # Reproduzir SE de erro
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Reproduzir SE de carregamento
    $game_system.se_play($data_system.load_se)
    # Ler dados do arquivo
    file = File.open(filename, "rb")
    read_save_data(file)
    file.close
    # Recuperar BGM e BGS
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    # Atualizar o mapa (rodas eventos de processo paralelo)
    $game_map.update
    # Trocar para a tela do mapa
    $scene = Scene_Map.new
  end
  
  #--------------------------------------------------------------------------
  # Cancelando o Processamento
  #--------------------------------------------------------------------------
  
  def on_cancel
    # Reproduzir SE de cancelamento
    $game_system.se_play($data_system.cancel_se)
    # Mudar para a tela de título
    $scene = Scene_Title.new
  end
  
  #--------------------------------------------------------------------------
  # Ler Dados do Arquivo
  #     file : arquivo que será lido (aberto)
  #--------------------------------------------------------------------------
  
  def read_save_data(file)
    # Ler dados dos Heróis para desenhar o arquivo de save
    characters = Marshal.load(file)
    # Ler o contador de Frames para obter o tempo de jogo
    Graphics.frame_count = Marshal.load(file)
    # Ler cada tipo de objeto do jogo
    $game_system        = Marshal.load(file)
    $game_switches      = Marshal.load(file)
    $game_variables     = Marshal.load(file)
    $game_self_switches = Marshal.load(file)
    $game_screen        = Marshal.load(file)
    $game_actors        = Marshal.load(file)
    $game_party         = Marshal.load(file)
    $game_troop         = Marshal.load(file)
    $game_map           = Marshal.load(file)
    $game_player        = Marshal.load(file)
    # Se o número mágico for diferente ao de quando foi salvo
    # (Se uma edição foi adicionada por um editor)
    if $game_system.magic_number != $data_system.magic_number
      # Carregar mapa
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    # Atualizar membros do grupo
    $game_party.refresh
  end
end
