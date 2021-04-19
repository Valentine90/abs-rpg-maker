#==============================================================================
# Arrow_Enemy
#------------------------------------------------------------------------------
# É o ponteiro que indica o inimigo a ser escolhido na batalha
#==============================================================================

class Arrow_Enemy < Arrow_Base
 
  #--------------------------------------------------------------------------
  # Utilizar o Inimigo que for Selecionado
  #--------------------------------------------------------------------------
 
  def enemy
    return $game_troop.enemies[@index]
  end
 
  #--------------------------------------------------------------------------
  # Renovação do Frame
  #--------------------------------------------------------------------------
 
  def update
    super
    # Estará no ar se o inimigo não estiver selecionado
    $game_troop.enemies.size.times do
      break if self.enemy.exist?
      @index += 1
      @index %= $game_troop.enemies.size
    end
    # Ao apertar a seta da direita
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
    end
    # Ao apertar a seta da esquerda
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += $game_troop.enemies.size - 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
    end
    # Opções das coordenadas dos Sprites
    if self.enemy != nil
      self.x = self.enemy.screen_x
      self.y = self.enemy.screen_y
    end
  end
 
  #--------------------------------------------------------------------------
  # Atualização da Janela de ajuda
  #--------------------------------------------------------------------------
 
  def update_help
    # Mostra o Status do Herói na janela de ajuda
    @help_window.set_enemy(self.enemy)
  end
end
