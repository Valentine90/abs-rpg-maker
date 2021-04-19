#==============================================================================
# Window_BattleStatus
#------------------------------------------------------------------------------
# É a janela que exibe os Status dos Heróis durante uma batalha.
#==============================================================================

class Window_BattleStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(0, 320, 640, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    @level_up_flags = [false, false, false, false]
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Exibição
  #--------------------------------------------------------------------------
  
  def dispose
    super
  end
  
  #--------------------------------------------------------------------------
  # Configuração da Flag de Subida de Nível
  #
  #     actor_index : índice de Heróis
  #--------------------------------------------------------------------------
  
  def level_up(actor_index)
    @level_up_flags[actor_index] = true
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    @item_max = $game_party.actors.size
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      actor_x = i * 160 + 4
      draw_actor_name(actor, actor_x, 0)
      draw_actor_hp(actor, actor_x, 32, 120)
      draw_actor_sp(actor, actor_x, 64, 120)
      if @level_up_flags[i]
        self.contents.font.color = normal_color
        self.contents.draw_text(actor_x, 96, 120, 32, "Nível Acima!")
      else
        draw_actor_state(actor, actor_x, 96)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Aqui é exibida uma descosiderável opacidade
    if $game_temp.battle_main_phase
      self.contents_opacity -= 4 if self.contents_opacity > 191
    else
      self.contents_opacity += 4 if self.contents_opacity < 255
    end
  end
end
