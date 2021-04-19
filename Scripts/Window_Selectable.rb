#==============================================================================
# Window_Selectable
#------------------------------------------------------------------------------
# Aqui é definida a função de movimento do cursor e o scroll nas janelas
#==============================================================================

class Window_Selectable < Window_Base
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :index                    # Posição do Cursor
  attr_reader   :help_window              # Janela de Ajuda
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     x      : Coordenadas X da janela
  #     y      : Coordenadas Y da janela
  #     width  : Comprimento da janela
  #     height : Altura da janela
  #--------------------------------------------------------------------------
  
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = -1
  end
  
  #--------------------------------------------------------------------------
  # Definir posição do cursor
  #
  #     index : Nova posição do cursor
  #--------------------------------------------------------------------------
  
  def index=(index)
    @index = index
    # Texto de ajuda atualizado (update_help se define em cada caso)
    if self.active and @help_window != nil
      update_help
    end
    # Atualiza o retângulo de seleção
    update_cursor_rect
  end
  
  #--------------------------------------------------------------------------
  # Conhecimento do Número de Linhas
  #--------------------------------------------------------------------------
  
  def row_max
    # O número de linhas é calculado pelo número de objetos e o número de 
    # seqüências
    return (@item_max + @column_max - 1) / @column_max
  end
 
  #--------------------------------------------------------------------------
  # Aquisição de uma Linha Superior
  #--------------------------------------------------------------------------
  def top_row
    # É o calculo para se obter a linha superior a partir da altura da linha. 
    # É divido por 32.
    return self.oy / 32
  end
 
  #--------------------------------------------------------------------------
  # Definição da Linha Superior
  #
  #     row : Linha do Cabeçalho
  #--------------------------------------------------------------------------
 
  def top_row=(row)
    # Se row estiver abaixo de 0 ele se tornará 0
    if row < 0
      row = 0
    end
    # Se row for maior do que row_max -1, row se tornará row_max -1
    if row > row_max - 1
      row = row_max - 1
    end
    # Para row a altura de uma linha é 32
    self.oy = row * 32
  end
  
  #--------------------------------------------------------------------------
  # Definição do Número de Linhas que Podem ser Mostradas em uma Página.
  #--------------------------------------------------------------------------
  
  def page_row_max
    # Da altura de um frame é subtraído 32 e depois é divido por 32.
    return (self.height - 32) / 32
  end
  
  #--------------------------------------------------------------------------
  # Definição do Número de Itens que Podem ser Mostrados em uma página.
  #--------------------------------------------------------------------------
  
  def page_item_max
    # Definição de column_max pelo número de linhas e sequências
    return page_row_max * @column_max
  end
  
  #--------------------------------------------------------------------------
  # Opções da janela de Ajuda
  #---------------------------------------------------------------------------
  
  def help_window=(help_window)
    @help_window = help_window
    if self.active and @help_window != nil
      update_help
    end
  end
   
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    cursor_width = self.width / @column_max - 32
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 32 - self.oy
    self.cursor_rect.set(x, y, cursor_width, 32)
  end
 
  def update
    super
    if self.active and @item_max > 0 and @index >= 0
      if Input.repeat?(Input::DOWN)
        if (@column_max == 1 and Input.trigger?(Input::DOWN)) or
           @index < @item_max - @column_max
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + @column_max) % @item_max
        end
      end
      if Input.repeat?(Input::UP)
        if (@column_max == 1 and Input.trigger?(Input::UP)) or
           @index >= @column_max
          $game_system.se_play($data_system.cursor_se)
          @index = (@index - @column_max + @item_max) % @item_max
        end
      end
      if Input.repeat?(Input::RIGHT)
        if @column_max >= 2 and @index < @item_max - 1
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      end
      if Input.repeat?(Input::LEFT)
        if @column_max >= 2 and @index > 0
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
      if Input.repeat?(Input::R)
        if self.top_row + (self.page_row_max - 1) < (self.row_max - 1)
          $game_system.se_play($data_system.cursor_se)
          @index = [@index + self.page_item_max, @item_max - 1].min
          self.top_row += self.page_row_max
        end
      end
      if Input.repeat?(Input::L)
        if self.top_row > 0
          $game_system.se_play($data_system.cursor_se)
          @index = [@index - self.page_item_max, 0].max
          self.top_row -= self.page_row_max
        end
      end
    end
    if self.active and @help_window != nil
      update_help
    end
    update_cursor_rect
  end
end
