#==============================================================================
# Window_DebugRight
#------------------------------------------------------------------------------
# Esta é a janela que exibe um Switch e uma Variável independentemente
# na janela de depuração. (Modo Debug)
#==============================================================================

class Window_DebugRight < Window_Selectable
 
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
 
  attr_reader   :mode                     # Modo (0 = Switch, 1 = Variável)
  attr_reader   :top_id                   # Mostrar ID
 
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
 
  def initialize
    super(192, 0, 448, 352)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
    self.index = -1
    self.active = false
    @item_max = 10
    @mode = 0
    @top_id = 1
    refresh
  end
 
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
 
  def refresh
    self.contents.clear
    for i in 0..9
      if @mode == 0
        name = $data_system.switches[@top_id+i]
        status = $game_switches[@top_id+i] ? "[ON]" : "[OFF]"
      else
        name = $data_system.variables[@top_id+i]
        status = $game_variables[@top_id+i].to_s
      end
      if name == nil
        name = ''
      end
      id_text = sprintf("%04d:", @top_id+i)
      width = self.contents.text_size(id_text).width
      self.contents.draw_text(4, i * 32, width, 32, id_text)
      self.contents.draw_text(12 + width, i * 32, 296 - width, 32, name)
      self.contents.draw_text(312, i * 32, 100, 32, status, 2)
    end
  end
  
  #--------------------------------------------------------------------------
  # Opções do Modo
  #
  #     id : Novo Modo
  #--------------------------------------------------------------------------
 
  def mode=(mode)
    if @mode != mode
      @mode = mode
      refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # Mostrar Opções do ID
  #
  #     id : Novo ID
  #--------------------------------------------------------------------------
  
  def top_id=(id)
    if @top_id != id
      @top_id = id
      refresh
    end
  end
end
