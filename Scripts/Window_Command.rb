#==============================================================================
# Window_Command
#------------------------------------------------------------------------------
# Esta é a janela que exibe as escolhas.
#==============================================================================

class Window_Command < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     width    : largura da janela
  #     commands : ordem dos comandos
  #--------------------------------------------------------------------------
  def initialize(width, commands)
    # Aqui é calculada a altura da janela em relação ao número de escolhas
    super(0, 0, width, commands.size * 32 + 32)
    @item_max = commands.size
    @commands = commands
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    refresh
    self.index = 0
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, normal_color)
    end
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Item
  #
  #     index : índice
  #     color : cor do texto
  #--------------------------------------------------------------------------
  
  def draw_item(index, color)
    self.contents.font.color = color
    rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
  end
  
  #--------------------------------------------------------------------------
  # Desabitar Item 
  #
  #     index : índice
  #--------------------------------------------------------------------------
  
  def disable_item(index)
    draw_item(index, disabled_color)
  end
end
