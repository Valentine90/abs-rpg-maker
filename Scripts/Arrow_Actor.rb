#==============================================================================
# Arrow_Actor
#------------------------------------------------------------------------------
# É o ponteiro que indica o Herói a ser escolhido na batalha
#==============================================================================

class Arrow_Actor < Arrow_Base
  
  #--------------------------------------------------------------------------
  # Utilizar o Herói que for Selecionado
  #--------------------------------------------------------------------------
 
  def actor
    return $game_party.actors[@index]
  end
 
  #--------------------------------------------------------------------------
  # Renovação do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Ao apertar a seta da direita
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index += 1
      @index %= $game_party.actors.size
    end
    # Ao apertar a seta da esquerda
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index += $game_party.actors.size - 1
      @index %= $game_party.actors.size
    end
    # Opções das coordenadas dos Sprites
    if self.actor != nil
      self.x = self.actor.screen_x
      self.y = self.actor.screen_y
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização da Janela de Ajuda
  #--------------------------------------------------------------------------
  
  def update_help
    # Mostra o Status do Herói na janela de ajuda
    @help_window.set_actor(self.actor)
  end
end
