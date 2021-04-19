#==============================================================================
# Window_ShopCommand
#------------------------------------------------------------------------------
# Janela de seleção de tipo de negócio em uma loja
#==============================================================================

class Window_ShopCommand < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(0, 64, 480, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
       self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
    @item_max = 3
    @column_max = 3
    @commands = ["Comprar", "Vender", "Sair"]
    refresh
    self.index = 0
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # Desenho do Item
  #
  #     index : Número do objeto
  #--------------------------------------------------------------------------
  
  def draw_item(index)
    x = 4 + index * 160
    self.contents.draw_text(x, 0, 128, 32, @commands[index])
  end
end
