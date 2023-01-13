#==============================================================================
# ** Sprite_HUD
#------------------------------------------------------------------------------
# Esta classe exibe na tela do jogo o HP, SP e experiência do herói.
#------------------------------------------------------------------------------
# Autor: Valentine
# Última atualização: 13/01/2023
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
    refresh
  end
  #--------------------------------------------------------------------------
  # * Atualização
  #--------------------------------------------------------------------------
  def refresh
    actor = $game_party.actors[0]
    background = RPG::Cache.picture('Background')
    bars = RPG::Cache.picture('Bars')
    @old_hp = actor.hp
    @old_sp = actor.sp
    @old_exp = actor.now_exp
    self.bitmap.clear
    self.bitmap.blt(0, 0, background, background.rect)
    self.bitmap.blt(24, 0, bars, Rect.new(0, 0, bars.width * actor.hp / actor.maxhp, 15))
    self.bitmap.blt(24, 22, bars, Rect.new(0, 15, bars.width * actor.sp / actor.maxsp, 15))
    exp_bar_width = actor.level < $data_actors[1].final_level ? bars.width * actor.now_exp / actor.next_exp : bars.width
    self.bitmap.blt(24, 44, bars, Rect.new(0, 30, exp_bar_width, 15))
    self.bitmap.draw_text(24, -2, bars.width, self.bitmap.font.size + 2, "#{actor.hp}/#{actor.maxhp}", 1)
    self.bitmap.draw_text(24, 21, bars.width, self.bitmap.font.size + 2, "#{actor.sp}/#{actor.maxsp}", 1)
    self.bitmap.draw_text(24, 43, bars.width, self.bitmap.font.size + 2, "#{actor.now_exp}/#{actor.next_exp}", 1)
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    super
    refresh if something_changed?
  end
  #--------------------------------------------------------------------------
  # * Algo mudou?
  #--------------------------------------------------------------------------
  def something_changed?
    @old_hp != $game_party.actors[0].hp or
     @old_sp != $game_party.actors[0].sp or
     @old_exp != $game_party.actors[0].now_exp
  end
end
