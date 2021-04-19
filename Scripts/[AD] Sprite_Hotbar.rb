#==============================================================================
# ** Sprite_Hotbar
#------------------------------------------------------------------------------
# Autor: Valentine
#==============================================================================

class Sprite_Hotbar < Sprite
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #--------------------------------------------------------------------------
  def initialize
    super
    self.bitmap = Bitmap.new(266, 26)
    self.x = 225
    self.y = 13
    self.z = 100
    self.bitmap.font.size = 12
    @back = RPG::Cache.picture('Hotkey01')
    @mask = RPG::Cache.picture('Hotkey02')
    @actor = $game_party.actors[0]
    refresh
  end
  #--------------------------------------------------------------------------
  # * Atualização
  #--------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    self.bitmap.blt(0, 0, @back, @back.rect)
    HOTKEYS.each_index do |i|
      next if !@actor.hotkeys[HOTKEYS[i]] or @actor.hotkeys[HOTKEYS[i]] == 0
      item = @actor.hotkeys[HOTKEYS[i]] > 0 ? $data_skills[@actor.hotkeys[HOTKEYS[i]]] : $data_items[@actor.hotkeys[HOTKEYS[i]].abs]
      icon = RPG::Cache.icon(item.icon_name)
      x = i % HOTKEYS.size * 30
      self.bitmap.blt(x + 1, 1, icon, icon.rect)
      # Desenha a quantidade do item
      self.bitmap.draw_text(x, 14, 26, self.bitmap.font.size + 2, $game_party.item_number(@actor.hotkeys[HOTKEYS[i]].abs).to_s, 2) if @actor.hotkeys[HOTKEYS[i]] < 0
    end
    self.bitmap.blt(0, 0, @mask, @mask.rect)
  end
end
