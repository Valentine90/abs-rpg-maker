#==============================================================================
# Scene_Debug
#------------------------------------------------------------------------------
# Esta é a classe que processa a tela de Debug (Modo de Depuração)
#==============================================================================

class Scene_Debug
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Aqui, vamos criar a janela do modo de depuração
    # Definimos o tamanho e a cor da janela
    @left_window = Window_DebugLeft.new
    @right_window = Window_DebugRight.new
    @help_window = Window_Base.new(192, 352, 448, 128)
    @help_window.contents = Bitmap.new(406, 96)
    # Agora, definimos as demais opções da janela
    # Como ID, Modo, Posição..
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    # Executamos uma transição de tela
    Graphics.transition
    # Loop Principal
    loop do
      # Atualizamos a tela do jogo
      Graphics.update
      # Atualizamos as teclas (Input)
      Input.update
      # Atualizamos a janela
      update
      # O loop será interrompido se houverem alterações na tela
      if $scene != self
        break
      end
    end
    # Atualizamos o mapa do jogo
    $game_map.refresh
    # Preparamos uma transição de tela
    Graphics.freeze
    # E exibimos a janela
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualização da Janela
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    # Memorizar Objeto Selecionado
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    # Quando a janela esquerda for ativada. chamamos o 'update_left'
    if @left_window.active
      update_left
      return
    end
    # Quando a janela direita for ativada. chamamos o 'update_right'
    if @right_window.active
      update_right
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização (Se a janela da esquerda estiver ativada)
  #--------------------------------------------------------------------------
  def update_left
    # Ao apertar B
    if Input.trigger?(Input::B)
      # Realizar SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Cambiar a pantalla del mapa
      $scene = Scene_Map.new
      return
    end
    # Ao apertar C
    if Input.trigger?(Input::C)
      # Realizar SE de escolha
      $game_system.se_play($data_system.decision_se)
      # Mostrar Ajuda
      if @left_window.mode == 0
        text1 = "C (Intro) : Ativar / Desativar"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
      else
        text1 = "← : -1   → : +1"
        text2 = "L (Anterior) : -10"
        text3 = "R (Próxima) : +10"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
        @help_window.contents.draw_text(4, 32, 406, 32, text2)
        @help_window.contents.draw_text(4, 64, 406, 32, text3)
      end
      # Ativação da janela rápida
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
      return
    end
  end
  #--------------------------------------------------------------------------
  # Atualização (Se a janela rápida estiver ativa)
  #--------------------------------------------------------------------------
  def update_right
    # Ao apertar B
    if Input.trigger?(Input::B)
      # Realizar SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Ativação da janela esquerda
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      # Mostrar Ajuda
      @help_window.contents.clear
      return
    end
    # Escolha de Switch/ID da Variável
    current_id = @right_window.top_id + @right_window.index
    # Se for Switch
    if @right_window.mode == 0
      # Ao apertar C
      if Input.trigger?(Input::C)
        # Realizar SE de escolha
        $game_system.se_play($data_system.decision_se)
        # Inverter ON/OFF
        $game_switches[current_id] = (not $game_switches[current_id])
        @right_window.refresh
        return
      end
    end
    # Se for Variável
    if @right_window.mode == 1
      # Ao apertar a seta da direita
      if Input.repeat?(Input::RIGHT)
        # Realizar SE de cursor
        $game_system.se_play($data_system.cursor_se)
        # Aumentar em 1
        $game_variables[current_id] += 1
        # O máximo
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # Ao apertar a seta da esquerda
      if Input.repeat?(Input::LEFT)
        # Realizar SE de cursor
        $game_system.se_play($data_system.cursor_se)
        # Reduzir em 1
        $game_variables[current_id] -= 1
        # O mínimo
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
      # Ao apertar R
      if Input.repeat?(Input::R)
        # Realizar SE de cursor
        $game_system.se_play($data_system.cursor_se)
        # Aumentar em 10
        $game_variables[current_id] += 10
        # O máximo
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # Ao apertar L
      if Input.repeat?(Input::L)
        # Realizar SE de cursor
        $game_system.se_play($data_system.cursor_se)
        # Diminuir 10
        $game_variables[current_id] -= 10
        # O mínimo
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
    end
  end
end
