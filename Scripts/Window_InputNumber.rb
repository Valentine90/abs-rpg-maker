#==============================================================================
# Window_InputNumber
#------------------------------------------------------------------------------
# Esta janela é utilizada para a Entrada Numérica
#==============================================================================

class Window_InputNumber < Window_Base
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     digits_max : número máximo
  #--------------------------------------------------------------------------
  
  def initialize(digits_max)
    @digits_max = digits_max
    @number = 0
    # Aqui é calculado a comrimento do cursor de 0 a 9
    dummy_bitmap = Bitmap.new(32, 32)
    @cursor_width = dummy_bitmap.text_size("0").width + 8
    dummy_bitmap.dispose
    super(0, 0, @cursor_width * @digits_max + 32, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z += 9999
    self.opacity = 0
    @index = 0
    refresh
    update_cursor_rect
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Número
  #--------------------------------------------------------------------------
  
  def number
    return @number
  end
  
  #--------------------------------------------------------------------------
  # Definir Número
  #     number : número novo
  #--------------------------------------------------------------------------
  
  def number=(number)
    @number = [[number, 0].max, 10 ** @digits_max - 1].min
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Retângulo de Seleção
  #--------------------------------------------------------------------------
  
  def update_cursor_rect
    self.cursor_rect.set(@index * @cursor_width, 0, @cursor_width, 32)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Se você apertar o direcional para cima ou para baixo...
    if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)
      # Definir número inicial como 0
      place = 10 ** (@digits_max - 1 - @index)
      n = @number / place % 10
      @number -= n * place
      # Caso aperte para cima, 1 é adicionado, caso aperte para baixo, 
      # 1 é diminuído
      n = (n + 1) % 10 if Input.repeat?(Input::UP)
      n = (n + 9) % 10 if Input.repeat?(Input::DOWN)
      # Resetar número atual
      @number += n * place
      refresh
    end
    # Botão á direita
    if Input.repeat?(Input::RIGHT)
      if @digits_max >= 2
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 1) % @digits_max
      end
    end
    # Botão à esquerda
    if Input.repeat?(Input::LEFT)
      if @digits_max >= 2
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + @digits_max - 1) % @digits_max
      end
    end
    update_cursor_rect
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    s = sprintf("%0*d", @digits_max, @number)
    for i in 0...@digits_max
      self.contents.draw_text(i * @cursor_width + 4, 0, 32, 32, s[i,1])
    end
  end
end
