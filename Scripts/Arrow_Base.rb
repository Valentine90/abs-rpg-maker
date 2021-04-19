#==============================================================================
# Arrow_Base
#------------------------------------------------------------------------------
# É o sprite para mostrar o cursor de seleção na batalha
# Esta classe é utilizada em Arrow_Enemy e Arrow_Actor
#==============================================================================

class Arrow_Base < Sprite
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :index                    # Posição do cursor
  attr_reader   :help_window              # Janela de Ajuda
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     viewport : Ponto de Vista
  #--------------------------------------------------------------------------
  
  def initialize(viewport)
    super(viewport)
    self.bitmap = RPG::Cache.windowskin($game_system.windowskin_name)
    self.ox = 16
    self.oy = 64
    self.z = 2500
    @blink_count = 0
    @index = 0
    @help_window = nil
    update
  end
  
  #--------------------------------------------------------------------------
  # Opções de Posição de Cursor
  #
  #     index : Indica nova posição do cursor
  #--------------------------------------------------------------------------
  
  def index=(index)
    @index = index
    update
  end
  
  #--------------------------------------------------------------------------
  # Opções da Janela de Ajuda
  #
  #     help_window : Janela de Ajuda
  #--------------------------------------------------------------------------
  
  def help_window=(help_window)
    @help_window = help_window
    # Atualizar texto
    # (update_help definido em cada caso)
    if @help_window != nil
      update_help
    end
  end
  
  #--------------------------------------------------------------------------
  # Renovação do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar conta
    @blink_count = (@blink_count + 1) % 8
    # Fixar o retângulo da conta
    if @blink_count < 4
      self.src_rect.set(128, 96, 32, 32)
    else
      self.src_rect.set(160, 96, 32, 32)
    end
    # Atualizar o texto
    # (update_help está definido em cada caso)
    if @help_window != nil
      update_help
    end
  end
end
