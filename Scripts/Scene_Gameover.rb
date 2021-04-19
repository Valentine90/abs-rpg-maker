#==============================================================================
# Scene_Gameover
#------------------------------------------------------------------------------
# Esta classe executa a tela de final de jogo (Game Over)
#==============================================================================

class Scene_Gameover

  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
    def main
    # Criação dos gráficos de Gameover
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover($data_system.gameover_name)
    # Interrompe o BGM e o BGS
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    # Reproduz o ME do Gameover
    $game_system.me_play($data_system.gameover_me)
    # Executa a Transição
    Graphics.transition(120)
    # Loop principal
    loop do
      # Atualiza a tela do jogo
      Graphics.update
      # Atualiza entradas
      Input.update
      # Renova o Frame
      update
      # Interrompe os loops de transição de tela
      if $scene != self
        break
      end
    end
    # Prepara a Transição
    Graphics.freeze
    # Mostrar gráficos de Gamover
    @sprite.bitmap.dispose
    @sprite.dispose
    # Executa a Transição
    Graphics.transition(40)
    # Prepara a Transição
    Graphics.freeze
    # Se for Teste de Batalha
    if $BTEST
      $scene = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # Renovação do Frame
  #--------------------------------------------------------------------------
  
  def update
  # Se apertar a tecla C
    if Input.trigger?(Input::C)
    # Vai para a Tela de Título
      $scene = Scene_Title.new
    end
  end
end
