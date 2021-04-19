#==============================================================================
# Window_Message
#------------------------------------------------------------------------------
# Esta janela será usada para exibir textos
#==============================================================================

class Window_Message < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    super(80, 304, 480, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    self.z = 9998
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    self.active = false
    self.index = -1
  end
  
  #--------------------------------------------------------------------------
  # Disposição
  #--------------------------------------------------------------------------
  
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # Fim da Mensagem
  #--------------------------------------------------------------------------
  
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    # Limpar a flag de mensagem
    @contents_showing = false
    # Chamar mensagem
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    # Limpar variáveis relacionadas ao texto, escolhas, e entrada numérica
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    # Abrir janela do dinheiro
    if @gold_window != nil
      @gold_window.dispose
      @gold_window = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualizar
  #--------------------------------------------------------------------------
  
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    x = y = 0
    @cursor_width = 0
    # Identificar se for escolha
    if $game_temp.choice_start == 0
      x = 8
    end
    # Se for uma mensagem em espera
    if $game_temp.message_text != nil
      text = $game_temp.message_text
      # Controlar processamento do texto
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # Alterar "\\\\" para "\000" por conveniência
      text.gsub!(/\\\\/) { "\000" }
      # Mudar "\\C" para "\001" e "\\G" para "\002"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      # Apertar o botão para confirmar
      while ((c = text.slice!(/./m)) != nil)
        # Se \\
        if c == "\000"
          # Retornar ao texto original
          c = "\\"
        end
        # Se \C[n]
        if c == "\001"
          # Alterer a cor do texto
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          # ir ao próximo texto
          next
        end
        # Se \G
        if c == "\002"
          # Abrir janela de dinheiro
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
          # Ir ao próximo texto
          next
        end
        # Quebra de linha
        if c == "\n"
          # Atualizar largura do cursor se for escolha
          if y >= $game_temp.choice_start
            @cursor_width = [@cursor_width, x].max
          end
          # Adicionar 1 para y
          y += 1
          x = 0
          # Identificar se for escolha
          if y >= $game_temp.choice_start
            x = 8
          end
          # Ir ao próximo texto
          next
        end
        # Desenhar texto
        self.contents.draw_text(4 + x, 32 * y, 40, 32, c)
        # Adicionar x pela largura do texto
        x += self.contents.text_size(c).width
      end
    end
    # Se for escolha
    if $game_temp.choice_max > 0
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    # Se for entrada numérica
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
  end
  
  #--------------------------------------------------------------------------
  # Definir Posição da Tela e Opacidade
  #--------------------------------------------------------------------------
  
  def reset_window
    if $game_temp.in_battle
      self.y = 16
    else
      case $game_system.message_position
      when 0  # acima
        self.y = 16
      when 1  # centro
        self.y = 160
      when 2  # abaixo
        self.y = 304
      end
    end
    if $game_system.message_frame == 0
      self.opacity = 255
    else
      self.opacity = 0
    end
    self.back_opacity = 160
  end
  
  #--------------------------------------------------------------------------
  # Atualização Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Se Fade_in
    if @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
      end
      return
    end
    # Se for entrada numérica
    if @input_number_window != nil
      @input_number_window.update
      # Confirmar
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        # Exibir a janela de entrada numérica
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    # Se a mensagem estiver sendo exibida
    if @contents_showing
      # Se a escolha não estiver sendo exibida pausar
      if $game_temp.choice_max == 0
        self.pause = true
      end
      # Cancelar
      if Input.trigger?(Input::B)
        if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
        end
      end
      # Confirmar
      if Input.trigger?(Input::C)
        if $game_temp.choice_max > 0
          $game_system.se_play($data_system.decision_se)
          $game_temp.choice_proc.call(self.index)
        end
        terminate_message
      end
      return
    end
    # Se houver mensagem em espera ou estiver em escolha
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    # Se a mensagem não estiver sendo exibida
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Cursor de Seleção
  #--------------------------------------------------------------------------
  
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8, n * 32, @cursor_width, 32)
    else
      self.cursor_rect.empty
    end
  end
end
