#==============================================================================
# Window_SkillStatus
#------------------------------------------------------------------------------
# Esta janela exibe as magias do jogador na Tela de Habilidades 
#==============================================================================

class Window_SkillStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     actor : Herói
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 64, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
        self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_actor_state(@actor, 140, 0)
    draw_actor_hp(@actor, 284, 0)
    draw_actor_sp(@actor, 460, 0)
  end
end
