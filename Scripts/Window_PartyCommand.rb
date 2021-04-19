#==============================================================================
# Window_PartyCommand
#------------------------------------------------------------------------------
# Esta janela é utilizada para a escolha de atacar ou fugir em uma Batalha.
#==============================================================================

class Window_PartyCommand < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(0, 0, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.back_opacity = 160
    @commands = ["Lutar", "Fugir"]
    @item_max = 2
    @column_max = 2
    draw_item(0, normal_color)
    draw_item(1, $game_temp.battle_can_escape ? normal_color : disabled_color)
    self.active = false
    self.visible = false
    self.index = 0
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Item
  #
  #     index : índice de Itens
  #     color : cor do texto
  #--------------------------------------------------------------------------
  
  def draw_item(index, color)
    self.contents.font.color = color
    rect = Rect.new(160 + index * 160 + 4, 0, 128 - 10, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index], 1)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Retângulo de Seleção
  #--------------------------------------------------------------------------
  
  def update_cursor_rect
    self.cursor_rect.set(160 + index * 160, 0, 128, 32)
  end
end
