#==============================================================================
# Window_Target
#------------------------------------------------------------------------------
# Exibição de uma janela ao utilizar Itens ou Habilidades
#==============================================================================

class Window_Target < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(0, 0, 336, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
        self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
    self.z += 10
    @item_max = $game_party.actors.size
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Atualizar
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    for i in 0...$game_party.actors.size
      x = 4
      y = i * 116
      actor = $game_party.actors[i]
      draw_actor_name(actor, x, y)
      draw_actor_class(actor, x + 144, y)
      draw_actor_level(actor, x + 8, y + 32)
      draw_actor_state(actor, x + 8, y + 64)
      draw_actor_hp(actor, x + 152, y + 32)
      draw_actor_sp(actor, x + 152, y + 64)
    end
  end
  
  #--------------------------------------------------------------------------
  # Renovação do Retângulo de Seleção
  #--------------------------------------------------------------------------
  
  def update_cursor_rect
    # Se define a posição atual -1
    if @index < 0
      self.cursor_rect.set(0, 0, self.width - 32, @item_max * 116 - 20)
    else
      self.cursor_rect.set(0, @index * 116, self.width - 32, 96)
    end
  end
end