#==============================================================================
# Window_Help
#------------------------------------------------------------------------------
# Esta classe exibe uma janela de explicação para Habilidades e Itens.
#==============================================================================

class Window_Help < Window_Base
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(0, 0, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
  end
  
  #--------------------------------------------------------------------------
  # Definição do Texto
  #
  #  text  : texto exibido na janela
  #  align : alinhamento (0 = esquerda, 1 = centralizado, 2 = direita)
  #--------------------------------------------------------------------------
  
  def set_text(text, align = 0)
    # Caso algum alinhamento do texto ficar diferente de alguma outra parte...
    if text != @text or align != @align
      # O texto é redesenhado.
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, 32, text, align)
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
  
  #--------------------------------------------------------------------------
  # Definição do Herói
  #
  #     actor : exibição do Status do Persongem
  #--------------------------------------------------------------------------
  
  def set_actor(actor)
    if actor != @actor
      self.contents.clear
      draw_actor_name(actor, 4, 0)
      draw_actor_state(actor, 140, 0)
      draw_actor_hp(actor, 284, 0)
      draw_actor_sp(actor, 460, 0)
      @actor = actor
      @text = nil
      self.visible = true
    end
  end
  
  #--------------------------------------------------------------------------
  # Definição do Inimigo
  #
  #     enemy : Exibição do nome e do Status do Inimigo
  #--------------------------------------------------------------------------
  
  def set_enemy(enemy)
    text = enemy.name
    state_text = make_battler_state_text(enemy, 112, false)
    if state_text != ""
      text += "  " + state_text
    end
    set_text(text, 1)
  end
end
