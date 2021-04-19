#==============================================================================
# Scene_Name
#------------------------------------------------------------------------------
# Esta classe processa a Entrada de Nome
#==============================================================================

class Scene_Name
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Selecionar Herói
    @actor = $game_actors[$game_temp.name_actor_id]
    # Criar janelas
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
    # Executar transição
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar tela de jogo
      Graphics.update
      # Atualizar informações do jogo
      Input.update
      # Atualizar frame
      update
      # Abortar o loop caso a tela tenha sido alterada
      if $scene != self
        break
      end
    end
    # Preparar para transição
    Graphics.freeze
    # Exibir janelas
    @edit_window.dispose
    @input_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar janelas
    @edit_window.update
    @input_window.update
    # Se o botão B for pressionado
    if Input.repeat?(Input::B)
      # Se a posição do cursor for 0
      if @edit_window.index == 0
        return
      end
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # E deletar o texto
      @edit_window.back
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Se a posição do cursor for [OK]
      if @input_window.character == nil
        # Se o nome estiver vazio
        if @edit_window.name == ""
          # Retornar ao nome de origem
          @edit_window.restore_default
          # Se o nome estiver vazio
          if @edit_window.name == ""
            # Reproduzir SE de erro
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # Reproduzir SE de OK
          $game_system.se_play($data_system.decision_se)
          return
        end
        # Aterar nome do Herói
        @actor.name = @edit_window.name
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Mudar para a tela do Mapa
        $scene = Scene_Map.new
        return
      end
      # Se o número de caracteres estiver chegado ao limite
      if @edit_window.index == $game_temp.name_max_char
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Se não tiver nenhum caracter
      if @input_window.character == ""
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Adicianar caracter
      @edit_window.add(@input_window.character)
      return
    end
  end
end
