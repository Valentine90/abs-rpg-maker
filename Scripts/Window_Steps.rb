#==============================================================================
# Window_Steps
#------------------------------------------------------------------------------
# Janela que exibe a quantidade de passos
#==============================================================================

class Window_Steps < Window_Base
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(0, 0, 160, 96)
    self.contents = Bitmap.new(width - 32, height - 32)
        self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 120, 32, "Passos")
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 32, 120, 32, $game_party.steps.to_s, 2)
  end
end
