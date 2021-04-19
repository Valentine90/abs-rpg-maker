#==============================================================================
# Scene_End
#------------------------------------------------------------------------------
# Esta classe processa a tela de Game Over
#==============================================================================

class Scene_End
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Criar janela de comandos
    s1 = "Ir à Tela de Título"
    s2 = "Sair"
    s3 = "Cancelar"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 240 - @command_window.height / 2
    # Executar transição
    Graphics.transition
    # Lopping principal
    loop do
      # Atualizar tela de jogo
      Graphics.update
      # Atualizar entrada de informações
      Input.update
      # Atualização do Frame
      update
      # Aboratar loop se a tela se modificar
      if $scene != self
        break
      end
    end
    # preparar para a transição
    Graphics.freeze
    # Exibição da janela
    @command_window.dispose
    # Se alternar para a Tela de Título
    if $scene.is_a?(Scene_Title)
      # Desaparecimento gradual da tela
      Graphics.transition
      Graphics.freeze
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar janela de comandos
    @command_window.update
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Alternar para a tela de Menu
      $scene = Scene_Menu.new(5)
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Ramificação por posição na janela de comandos
      case @command_window.index
      when 0  # Ir à tela de título
        command_to_title
      when 1  # Sair
        command_shutdown
      when 2  # Cancelar
        command_cancel
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Processamento na Escolha do Comando Ir à Tela de Título
  #--------------------------------------------------------------------------
  
  def command_to_title
    # Reproduzir SE de OK
    $game_system.se_play($data_system.decision_se)
    # Diminuir gradualmente o volume de GBM, BGS e ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # Alternar para a tela de Título
    $scene = Scene_Title.new
  end
  
  #--------------------------------------------------------------------------
  # Processamento na Escolha do Comando Sair
  #--------------------------------------------------------------------------
  
  def command_shutdown
    # Repdoduzir SE de OK
    $game_system.se_play($data_system.decision_se)
    # Diminuir gradualmente o volume de GBM, BGS e ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # Sair
    $scene = nil
  end
  
  #--------------------------------------------------------------------------
  # Processamento na Escolha do Comando Cancelar
  #--------------------------------------------------------------------------
  
  def command_cancel
    # Reproduzir SE de OK
    $game_system.se_play($data_system.decision_se)
    # Alternar para a tela do Menu
    $scene = Scene_Menu.new(5)
  end
end
