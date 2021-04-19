#==============================================================================
# Scene_Status
#------------------------------------------------------------------------------
# Esta janela exibe o Status
#==============================================================================

class Scene_Status
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     actor_index : índice do Herói
  #--------------------------------------------------------------------------
  
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Selecionar Herói
    @actor = $game_party.actors[@actor_index]
    # Criar a janela de Status
    @status_window = Window_Status.new(@actor)
    # Executar Transição
    Graphics.transition
    # Loop principal
    loop do
      # Aqui a tela é atualizada
      Graphics.update
      # E os dados também
      Input.update
      # Então os frames são atualizados
      update
      # Abortar loop se a janela for alterada
      if $scene != self
        break
      end
    end
    # preparar para transição
    Graphics.freeze
    # E a janela é exibida
    @status_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do frame
  #--------------------------------------------------------------------------
  
  def update
    # Caso o botão B seja pressionado
    if Input.trigger?(Input::B)
      # É tocada a música SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Mudar para a tela do Menu
      $scene = Scene_Menu.new(3)
      return
    end
    # Caso o botão R seja pressionado
    if Input.trigger?(Input::R)
      # Reproduzir Se de seleção
      $game_system.se_play($data_system.cursor_se)
      # Para o próximo Herói
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # Mudar para uma tela de Status diferente
      $scene = Scene_Status.new(@actor_index)
      return
    end
    # Caso o botão L seja pressionado
    if Input.trigger?(Input::L)
      # Reproduzir SE de seleção
      $game_system.se_play($data_system.cursor_se)
      # Para o Herói anterior
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # Mudar para uma tela de Status diferente
      $scene = Scene_Status.new(@actor_index)
      return
    end
  end
end
