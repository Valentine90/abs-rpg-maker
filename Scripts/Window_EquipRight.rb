#==============================================================================
# Window_EquipRight
#------------------------------------------------------------------------------
# Esta janela exibe o que o Herói tem equipado na tela de Equipamentos.
#==============================================================================

class Window_EquipRight < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     actor : Herói
  #--------------------------------------------------------------------------
  
  def initialize(actor)
    super(272, 64, 368, 192)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
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
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    @data = []
    @data.push($data_weapons[@actor.weapon_id])
    @data.push($data_armors[@actor.armor1_id])
    @data.push($data_armors[@actor.armor2_id])
    @data.push($data_armors[@actor.armor3_id])
    @data.push($data_armors[@actor.armor4_id])
    @item_max = @data.size
    self.contents.font.color = system_color
    self.contents.draw_text(4, 32 * 0, 92, 32, $data_system.words.weapon)
    self.contents.draw_text(4, 32 * 1, 92, 32, $data_system.words.armor1)
    self.contents.draw_text(4, 32 * 2, 92, 32, $data_system.words.armor2)
    self.contents.draw_text(4, 32 * 3, 92, 32, $data_system.words.armor3)
    self.contents.draw_text(5, 32 * 4, 92, 32, $data_system.words.armor4)
    draw_item_name(@data[0], 92, 32 * 0)
    draw_item_name(@data[1], 92, 32 * 1)
    draw_item_name(@data[2], 92, 32 * 2)
    draw_item_name(@data[3], 92, 32 * 3)
    draw_item_name(@data[4], 92, 32 * 4)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Texto de Ajuda
  #--------------------------------------------------------------------------
  
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end
