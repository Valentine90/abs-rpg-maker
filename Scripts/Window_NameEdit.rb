#==============================================================================
# Window_NameEdit
#------------------------------------------------------------------------------
# Aqui é configurada a janela que exibe a edição de nome do Herói
#==============================================================================

class Window_NameEdit < Window_Base
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :name                     # nome
  attr_reader   :index                    # posição do cursor
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     actor    : Herói
  #     max_char : Número máximo de caracteres
  #--------------------------------------------------------------------------
  
  def initialize(actor, max_char)
    super(0, 0, 640, 128)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    @name = actor.name
    @max_char = max_char
    # Aqui é criado o string que limita o número de caracteres
    name_array = @name.split(//)[0...@max_char]
    @name = ""
    for i in 0...name_array.size
      @name += name_array[i]
    end
    @default_name = @name
    @index = name_array.size
    refresh
    update_cursor_rect
  end
  
  #--------------------------------------------------------------------------
  # Retornar ao Nome de Origem
  #--------------------------------------------------------------------------
  
  def restore_default
    @name = @default_name
    @index = @name.split(//).size
    refresh
    update_cursor_rect
  end
  
  #--------------------------------------------------------------------------
  # Adicionar Caracter
  #
  #     character : texto a ser adicioando
  #--------------------------------------------------------------------------
  
  def add(character)
    if @index < @max_char and character != ""
      @name += character
      @index += 1
      refresh
      update_cursor_rect
    end
  end
  
  #--------------------------------------------------------------------------
  # Deletar Caracter
  #--------------------------------------------------------------------------
  
  def back
    if @index > 0
      # Aqui está o comando que faz com que seja apagado de um em um caracter
      name_array = @name.split(//)
      @name = ""
      for i in 0...name_array.size-1
        @name += name_array[i]
      end
      @index -= 1
      refresh
      update_cursor_rect
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualizar
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    # Desenhar Nome
    name_array = @name.split(//)
    for i in 0...@max_char
      c = name_array[i]
      if c == nil
        c = "＿"
      end
      x = 320 - @max_char * 14 + i * 28
      self.contents.draw_text(x, 32, 28, 32, c, 1)
    end
    # Desenhar Gráfico
    draw_actor_graphic(@actor, 320 - @max_char * 14 - 40, 80)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Retângulo de Seleção
  #--------------------------------------------------------------------------
  
  def update_cursor_rect
    x = 320 - @max_char * 14 + @index * 28
    self.cursor_rect.set(x, 32, 28, 32)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    update_cursor_rect
  end
end
