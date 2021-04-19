#==============================================================================
# Window_ShopSell
#------------------------------------------------------------------------------
# É a janela que mostra o número de Itens que a venda possúi.
#==============================================================================

class Window_ShopSell < Window_Selectable
 
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
 
  def initialize
    super(0, 128, 640, 352)
    @column_max = 2
    refresh
    self.index = 0
  end
 
  #--------------------------------------------------------------------------
  # Aquisição do Item
  #--------------------------------------------------------------------------
 
  def item
    return @data[self.index]
  end
 
  #--------------------------------------------------------------------------
  # Atualizar
  #--------------------------------------------------------------------------
 
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for i in 1...$data_items.size
      if $game_party.item_number(i) > 0
        @data.push($data_items[i])
      end
    end
    for i in 1...$data_weapons.size
      if $game_party.weapon_number(i) > 0
        @data.push($data_weapons[i])
      end
    end
    for i in 1...$data_armors.size
      if $game_party.armor_number(i) > 0
        @data.push($data_armors[i])
      end
    end
    # Número do Item. Se não for 0 se cria uma desenho do Item.
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
          self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
 
  #--------------------------------------------------------------------------
  # Desenho do Item
  #
  #     index : Número do Item
  #--------------------------------------------------------------------------
  
  def draw_item(index)
    item = @data[index]
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    # Se a compra for possível uma cor indicará isso.
    if item.price > 0
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 4 + index % 2 * (288 + 32)
    y = index / 2 * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.draw_text(x + 240, y, 16, 32, ":", 1)
    self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
  end
 
  #--------------------------------------------------------------------------
  # Atualização do Texto de Ajuda
  #--------------------------------------------------------------------------
 
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end

