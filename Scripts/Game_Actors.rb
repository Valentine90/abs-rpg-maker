#==============================================================================
# Game_Actors
#------------------------------------------------------------------------------
# Esta classe considera as opções dos Heróis.
# Esta classe pode ser chamada utilizando $game_actors.
#==============================================================================

class Game_Actors
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    @data = []
  end
  
  #--------------------------------------------------------------------------
  # Uso do Herói
  #
  #     actor_id : ID do Herói
  #--------------------------------------------------------------------------
  
  def [](actor_id)
    if actor_id > 999 or $data_actors[actor_id] == nil
      return nil
    end
    if @data[actor_id] == nil
      @data[actor_id] = Game_Actor.new(actor_id)
    end
    return @data[actor_id]
  end
end
