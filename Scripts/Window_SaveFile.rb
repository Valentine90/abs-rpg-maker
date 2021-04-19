#==============================================================================
# Window_SaveFile
#------------------------------------------------------------------------------
# Aqui é configurada a janela que mostra os arquivos de save na tela de Carregar
#==============================================================================

class Window_SaveFile < Window_Base
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :filename                 # nome do arquivo
  attr_reader   :selected                 # selecionado
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     file_index : Índice de arquivos de save (0-3)
  #     filename   : nome do arquivo
  #--------------------------------------------------------------------------
  
  def initialize(file_index, filename)
    super(0, 64 + file_index % 4 * 104, 640, 104)
    self.contents = Bitmap.new(width - 32, height - 32)
    @file_index = file_index
    @filename = "Save#{@file_index + 1}.rxdata"
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      @characters = Marshal.load(file)
      @frame_count = Marshal.load(file)
      @game_system = Marshal.load(file)
      @game_switches = Marshal.load(file)
      @game_variables = Marshal.load(file)
      @total_sec = @frame_count / Graphics.frame_rate
      file.close
    end
    refresh
    @selected = false
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    # Desenhar número do arquivo
    self.contents.font.color = normal_color
    name = "File#{@file_index + 1}"
    self.contents.draw_text(4, 0, 600, 32, name)
    @name_width = contents.text_size(name).width
    # Se o arquivo existir...
    if @file_exist
      # Desenhar Heróis
      for i in 0...@characters.size
        bitmap = RPG::Cache.character(@characters[i][0], @characters[i][1])
        cw = bitmap.rect.width / 4
        ch = bitmap.rect.height / 4
        src_rect = Rect.new(0, 0, cw, ch)
        x = 300 - @characters.size * 32 + i * 64 - cw / 2
        self.contents.blt(x, 68 - ch, bitmap, src_rect)
      end
      # Desenhar tempo de jogo
      hour = @total_sec / 60 / 60
      min = @total_sec / 60 % 60
      sec = @total_sec % 60
      time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 8, 600, 32, time_string, 2)
      # Aqui o desenho é estampado
      self.contents.font.color = normal_color
      time_string = @time_stamp.strftime("%d/%m/%Y %H:%M")
      self.contents.draw_text(4, 40, 600, 32, time_string, 2)
    end
  end
  
  #--------------------------------------------------------------------------
  # Definir Selecionado
  #     selected : novo selecionado (true = selecionado false = não selecionado)
  #--------------------------------------------------------------------------
  
  def selected=(selected)
    @selected = selected
    update_cursor_rect
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Retângulo de Seleção
  #--------------------------------------------------------------------------
  
  def update_cursor_rect
    if @selected
      self.cursor_rect.set(0, 0, @name_width + 8, 32)
    else
      self.cursor_rect.empty
    end
  end
end
