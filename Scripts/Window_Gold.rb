#==============================================================================
# Window_Gold
#------------------------------------------------------------------------------
# Janela que exibe o dinheiro
#==============================================================================

class Window_Gold < Window_Base
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(0, 0, 160, 64)
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
    cx = contents.text_size($data_system.words.gold).width
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 120-cx-2, 32, $game_party.gold.to_s, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(124-cx, 0, cx, 32, $data_system.words.gold, 2)
  end
end
