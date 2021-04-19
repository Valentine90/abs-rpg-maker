#==============================================================================
# Game_Troop
#------------------------------------------------------------------------------
# Esta é a classe que trata do Grupo de Inimigos. 
# Esta classe é chamada $game_troop.
#==============================================================================

class Game_Troop
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    # Aqui é criada a ordem de batalha do Grupo de Inimigos
    @enemies = []
  end
  
  #--------------------------------------------------------------------------
  # São Selecionados os Inimigos
  #--------------------------------------------------------------------------
  
  def enemies
    return @enemies
  end
  
  #--------------------------------------------------------------------------
  # Configuração do Grupo
  #
  #     troop_id : ID da Tropa
  #--------------------------------------------------------------------------
  
  def setup(troop_id)
    # Aqui é definida a ordem de batalha dos Inimigos
    @enemies = []
    troop = $data_troops[troop_id]
    for i in 0...troop.members.size
      enemy = $data_enemies[troop.members[i].enemy_id]
      if enemy != nil
        @enemies.push(Game_Enemy.new(troop_id, i))
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Seleção Randômica de Inimigo no Grupo
  #
  #     hp0 : Limitação a Inimigos com HP=0
  #--------------------------------------------------------------------------
  
  def random_target_enemy(hp0 = false)
    # Aqui é criada uma roleta para a seleção randômica
    roulette = []
    # Loop
    for enemy in @enemies
      # Define os Inimigos habilitados à batalha (considera o HP)
      if (not hp0 and enemy.exist?) or (hp0 and enemy.hp0?)
        # Se o Inimigo tiver HP>0 ele é adicionado à roleta de seleção
        roulette.push(enemy)
      end
    end
    # Se o tamanho da roleta de seleção for igual a 0, o turno é passado
    if roulette.size == 0
      return nil
    end
    # A roleta é girada e um Inimigo é selecionado
    return roulette[rand(roulette.size)]
  end
  
  #--------------------------------------------------------------------------
  # Seleção Randômica de Alvo do Inimigo (Considera se o HP=0)
  #--------------------------------------------------------------------------
  
  def random_target_enemy_hp0
    return random_target_enemy(true)
  end
  
  #--------------------------------------------------------------------------
  # Suavização do Alvo do Inimigo
  #
  #     enemy_index : Índice de Inimigos
  #--------------------------------------------------------------------------
  
  def smooth_target_enemy(enemy_index)
    # Aqui é selecionado um Inimigo
    enemy = @enemies[enemy_index]
    # Verifica-se a existência deste
    if enemy != nil and enemy.exist?
      return enemy
    end
    # Loop
    for enemy in @enemies
      # Caso o Inimigo exista, a batalha continua
      if enemy.exist?
        return enemy
      end
    end
  end
end
