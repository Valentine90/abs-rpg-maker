#==============================================================================
# Window_Skill
#------------------------------------------------------------------------------
# É a janela que mostra as Habilidades
#==============================================================================

class Window_Skill < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     ator : Herói
  #--------------------------------------------------------------------------
  
  def initialize(actor)
    super(0, 128, 640, 352)
    @actor = actor
    @column_max = 2
    refresh
    self.index = 0
    # Se for em batalha, mover a janela e colocá-la em translucidez
    if $game_temp.in_battle
      self.y = 64
      self.height = 256
      self.back_opacity = 160
    end
  
    end
  
  #--------------------------------------------------------------------------
  # Uso de Habilidades
  #--------------------------------------------------------------------------
 
  def skill
    return @data[self.index]
  end
 
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
 
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for i in 0...@actor.skills.size
      skill = $data_skills[@actor.skills[i]]
      if skill != nil
        @data.push(skill)
      end
    end
    # Número de Itens. Se não for 0 desenhá-los.
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
  # Desenhando Itens
  #
  #     index : Número de Itens
  #--------------------------------------------------------------------------
  
  def draw_item(index)
    skill = @data[index]
    if @actor.skill_can_use?(skill.id)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 4 + index % 2 * (288 + 32)
    y = index / 2 * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(skill.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 204, 32, skill.name, 0)
    self.contents.draw_text(x + 232, y, 48, 32, skill.sp_cost.to_s, 2)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do texto de Ajuda
  #--------------------------------------------------------------------------
 
  def update_help
    @help_window.set_text(self.skill == nil ? "" : self.skill.description)
  end
end
