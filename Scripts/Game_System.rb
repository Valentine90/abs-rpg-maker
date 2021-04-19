#==============================================================================
# Game_System
#------------------------------------------------------------------------------
# Esta classe trata dos dados do sistema, coisas como BGM, SE, ME, etc.
# Esta classe pode ser chamada utilizando $game_system
#==============================================================================

class Game_System
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #
  # Aqui definimos as variáveis da classe. Para um maior entendimento
  # cada variável possui uma breve descrição.
  #--------------------------------------------------------------------------
  
  attr_reader   :map_interpreter          # Interpretador dos eventos do mapa
  attr_reader   :battle_interpreter       # Interpretador dos eventos de batalha
  attr_accessor :timer                    # Temporizador
  attr_accessor :timer_working            # Flag do processo de temporização
  attr_accessor :save_disabled            # Desativar os Saves 
  attr_accessor :menu_disabled            # Desativar o Menu
  attr_accessor :encounter_disabled       # Desativar os Encontros
  attr_accessor :message_position         # Posição de Exibição da Mensagem
  attr_accessor :message_frame            # Opções das Mensagens (Frame)
  attr_accessor :save_count               # Nº de Jogos Salvos (Saves)
  attr_accessor :magic_number             # Nº da Magia

  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  # Aqui fazemos a inicialização padrão da classe.
  #--------------------------------------------------------------------------
 
  def initialize
    @map_interpreter = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @message_position = 2
    @message_frame = 0
    @save_count = 0
    @magic_number = 0
  end
  
  #--------------------------------------------------------------------------
  # Uso de BGM
  #
  # Aqui é criada a função de reprodução de áudio (no caso, BGM)
  #
  #     bgm: Reproduzir BGM
  #--------------------------------------------------------------------------

  def bgm_play(bgm)
    @playing_bgm = bgm
    if bgm != nil and bgm.name != ""
      Audio.bgm_play("Audio/BGM/" + bgm.name, bgm.volume, bgm.pitch)
    else
      Audio.bgm_stop
    end
    Graphics.frame_reset
  end
  
  #--------------------------------------------------------------------------
  # Parar a Execução de BGM
  #--------------------------------------------------------------------------

  def bgm_stop
    Audio.bgm_stop
  end
  
  #--------------------------------------------------------------------------
  # Usando o Efeito de Fade (volume diminui gradualmente)
  #
  #     time: Tempo de Fade
  #--------------------------------------------------------------------------

  def bgm_fade(time)
    @playing_bgm = nil
    Audio.bgm_fade(time * 1000)
  end
  
  #--------------------------------------------------------------------------
  # Memorizar BGM
  #--------------------------------------------------------------------------

  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end
  
  #--------------------------------------------------------------------------
  # Reproduzir BGM Memorizado
  #--------------------------------------------------------------------------

  def bgm_restore
    bgm_play(@memorized_bgm)
  end
  
  #--------------------------------------------------------------------------
  # Uso de BGS
  #
  # Aqui é criada a função de reprodução de áudio (no caso, BGS)
  #
  #     bgs: Repoduzir BGS
  #--------------------------------------------------------------------------

  def bgs_play(bgs)
    @playing_bgs = bgs
    if bgs != nil and bgs.name != ""
      Audio.bgs_play("Audio/BGS/" + bgs.name, bgs.volume, bgs.pitch)
    else
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end
  
  #--------------------------------------------------------------------------
  # Usando o Efeito de Fade (volume diminui gradualmente)
  #
  #     time: Tempo de Fade
  #--------------------------------------------------------------------------

  def bgs_fade(time)
    @playing_bgs = nil
    Audio.bgs_fade(time * 1000)
  end
  
  #--------------------------------------------------------------------------
  # Memorizar BGS
  #--------------------------------------------------------------------------

  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end
  
  #--------------------------------------------------------------------------
  # Reproduzir BGS Memorizado
  #--------------------------------------------------------------------------

  def bgs_restore
    bgs_play(@memorized_bgs)
  end
  
  #--------------------------------------------------------------------------
  # Uso de ME
  #
  # Aqui é criada a função de reprodução de áudio (no caso, ME)
  #
  #     me: Repoduzir ME
  #--------------------------------------------------------------------------

  def me_play(me)
    if me != nil and me.name != ""
      Audio.me_play("Audio/ME/" + me.name, me.volume, me.pitch)
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end
  
  #--------------------------------------------------------------------------
  # Uso de SE
  #
  # Aqui é criada a função de reprodução de áudio (no caso, SE)
  #
  #     se: Repoduzir SE
  #--------------------------------------------------------------------------

  def se_play(se)
    if se != nil and se.name != ""
      Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)
    end
  end
  
  #--------------------------------------------------------------------------
  # Parar Execução de SE
  #--------------------------------------------------------------------------

  def se_stop
    Audio.se_stop
  end
  
  #--------------------------------------------------------------------------
  # BGM sendo Reproduzido
  #--------------------------------------------------------------------------

  def playing_bgm
    return @playing_bgm
  end
  
  #--------------------------------------------------------------------------
  # BGS sendo Reproduzido
  #--------------------------------------------------------------------------

  def playing_bgs
    return @playing_bgs
  end
  
  #--------------------------------------------------------------------------
  # Trabalhando com Windowskins
  #--------------------------------------------------------------------------
  # Nome do Windowskin
  #--------------------------------------------------------------------------

  def windowskin_name
    if @windowskin_name == nil
      return $data_system.windowskin_name
    else
      return @windowskin_name
    end
  end
  
  #--------------------------------------------------------------------------
  # Opções do nome do arquivo Windowskin
  #
  #     windowskin_name: Novo nome do arquivo Windowskin
  #--------------------------------------------------------------------------
 
  def windowskin_name=(windowskin_name)
    @windowskin_name = windowskin_name
  end
  
  #--------------------------------------------------------------------------
  # BGM de Batalha
  #
  # Aqui recebemos a configuração dada ao sistema. O sistema diz qual é
  # a BGM selecionada para ser executada durante a batalha.
  #--------------------------------------------------------------------------

  def battle_bgm
    if @battle_bgm == nil
      return $data_system.battle_bgm
    else
      return @battle_bgm
    end
  end
  
  #--------------------------------------------------------------------------
  # Opções da BGM de Batalha
  #
  #     battle_bgm: Nova BGM de Batalha
  #--------------------------------------------------------------------------

  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  
  #--------------------------------------------------------------------------
  # BGM do Final da Batalha
  #--------------------------------------------------------------------------

  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end
  
  #--------------------------------------------------------------------------
  # Opções da BGM do Final da Batalha
  #
  #     battle_end_me: Nova BGM do Final da Batalha
  #--------------------------------------------------------------------------
 
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------

  def update
    # Reduzir o temporizador em 1
    if @timer_working and @timer > 0
      @timer -= 1
    end
  end
end
