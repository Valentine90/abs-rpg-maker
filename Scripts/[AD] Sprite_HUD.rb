#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
# Autor: Valentine
#==============================================================================

class Sprite_HUD < Sprite
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #--------------------------------------------------------------------------
  def initialize
    super
    self.bitmap = Bitmap.new(176, 60)
    self.x = 13
    self.y = 13
    self.z = 100
    self.bitmap.font.name = 'Tahoma'
    self.bitmap.font.size = 14
    @back = RPG::Cache.picture('Background')
    @bars = RPG::Cache.picture('Bars')
    @actor = $game_party.actors[0]
    refresh
  end
  #--------------------------------------------------------------------------
  # * Algo mudou?
  #--------------------------------------------------------------------------
  def something_changed?
    @old_hp != @actor.hp or @old_sp != @actor.sp or @old_exp != @actor.now_exp
  end
  #--------------------------------------------------------------------------
  # * Atualização
  #--------------------------------------------------------------------------
  def refresh
    @old_hp = @actor.hp
    @old_sp = @actor.sp
    @old_exp = @actor.now_exp
    self.bitmap.clear
    self.bitmap.blt(0, 0, @back, @back.rect)
    self.bitmap.blt(24, 0, @bars, Rect.new(0, 0, @bars.width * @actor.hp / @actor.maxhp, 15))
    self.bitmap.blt(24, 22, @bars, Rect.new(0, 15, @bars.width * @actor.sp / @actor.maxsp, 15))
    self.bitmap.blt(24, 44, @bars, Rect.new(0, 30, @actor.level < $data_actors[1].final_level ? @bars.width * @actor.now_exp / @actor.next_exp : @bars.width, 15))
    self.bitmap.draw_text(24, -2, @bars.width, self.bitmap.font.size + 2, "#{@actor.hp}/#{@actor.maxhp}", 1)
    self.bitmap.draw_text(24, 21, @bars.width, self.bitmap.font.size + 2, "#{@actor.sp}/#{@actor.maxsp}", 1)
    self.bitmap.draw_text(24, 43, @bars.width, self.bitmap.font.size + 2, "#{@actor.now_exp}/#{@actor.next_exp}", 1)
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    super
    refresh if something_changed?
  end
end
