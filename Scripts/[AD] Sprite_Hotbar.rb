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
    refresh
  end
  #--------------------------------------------------------------------------
  # * Atualização
  #--------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    back = RPG::Cache.picture('Hotkey01')
    self.bitmap.blt(0, 0, back, back.rect)
    HOTKEYS.each_with_index do |key, i|
      hotkey = $game_party.actors[0].hotkeys[key]
      if hotkey and hotkey != 0
        item = hotkey > 0 ? $data_skills[hotkey] : $data_items[hotkey.abs]
        icon = RPG::Cache.icon(item.icon_name)
        x = i % HOTKEYS.size * 30
        self.bitmap.blt(x + 1, 1, icon, icon.rect)
        # Desenha a quantidade do item
        self.bitmap.draw_text(x, 14, 26, self.bitmap.font.size + 2, $game_party.item_number(hotkey.abs).to_s, 2) if hotkey < 0
      end
    end
    mask = RPG::Cache.picture('Hotkey02')
    self.bitmap.blt(0, 0, mask, mask.rect)
  end
end
