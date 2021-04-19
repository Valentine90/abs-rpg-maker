#==============================================================================
# Scene_File
#------------------------------------------------------------------------------
# Esta é uma superclasse para as telas de Salvar e Continuar
#==============================================================================

class Scene_File
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     help_text : string de texto exibido na janela de ajuda
  #--------------------------------------------------------------------------
  
  def initialize(help_text)
    @help_text = help_text
  end
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Criar janela de ajuda
    @help_window = Window_Help.new
    @help_window.set_text(@help_text)
    # Criar janela de salvar arquivos
    @savefile_windows = []
    for i in 0..3
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    # Selecionar o último arquivo para ser operado
    @file_index = $game_temp.last_file_index
    @savefile_windows[@file_index].selected = true
    # Executar transição
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar a tela de jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualização do Frame
      update
      # Abortar loop se a tela se modificar
      if $scene != self
        break
      end
    end
    # Preparar para transição
    Graphics.freeze
    # Exibição das janelas
    @help_window.dispose
    for i in @savefile_windows
      i.dispose
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar janelas
    @help_window.update
    for i in @savefile_windows
      i.update
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Chamar método: on_decision (definido pela superclasse)
      on_decision(make_filename(@file_index))
      $game_temp.last_file_index = @file_index
      return
    end
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Chamar método: on_cancel (definido pela superclasse)
      on_cancel
      return
    end
    # Se o direcional para baixo for pressionado
    if Input.repeat?(Input::DOWN)
      # Se não se repetir o direcional para baixo,
      # ou se a posição do cursor for a posição 3 ou maior
      if Input.trigger?(Input::DOWN) or @file_index < 3
        # Reproduzir SE de cursor
        $game_system.se_play($data_system.cursor_se)
        # Mover o cursor para baixo
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 1) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
    # Se o direcional para cima for pressionado
    if Input.repeat?(Input::UP)
      # Se não se repetir o direcional para cima,
      # ou se a posição do cursor for a posição 0 ou menor
      if Input.trigger?(Input::UP) or @file_index > 0
        # Reproduzir SE de cursor
        $game_system.se_play($data_system.cursor_se)
        # Mover o cursor para cima
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 3) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Criar o Nome do Arquivo
  #     file_index : índice de saves (0-3)
  #--------------------------------------------------------------------------
  
  def make_filename(file_index)
    return "Save#{file_index + 1}.rxdata"
  end
end
