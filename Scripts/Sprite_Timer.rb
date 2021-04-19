#==============================================================================
# Sprite_Timer
#------------------------------------------------------------------------------
# Aqui é controlado o sprite que exibe o Temporizador. Este, considera a
# a classe $game_system e automáticamente modifica as condições do sprite.
#==============================================================================

class Sprite_Timer < Sprite
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = "Arial"
    self.bitmap.font.size = 32
    self.x = 640 - self.bitmap.width
    self.y = 0
    self.z = 500
    update
  end
  
  #--------------------------------------------------------------------------
  # Aqui são Exibidos os Gráficos
  #--------------------------------------------------------------------------
  
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update
    super
    # Aqui é definida a condição de exibição do Temporizador
    self.visible = $game_system.timer_working
    # Se o Temporizador precisar ser redesenhado
    if $game_system.timer / Graphics.frame_rate != @total_sec
      # Aqui é limpo o conteúdo do sprite
      self.bitmap.clear
      # Neste comando é calculado o total do número de segundos 
      @total_sec = $game_system.timer / Graphics.frame_rate
      # Aqui é criado um string para o contador ser exibido
      min = @total_sec / 60
      sec = @total_sec % 60
      text = sprintf("%02d:%02d", min, sec)
      # Aqui a janela do Temporizador é desenhada
      self.bitmap.font.color.set(255, 255, 255)
      self.bitmap.draw_text(self.bitmap.rect, text, 1)
    end
  end
end
