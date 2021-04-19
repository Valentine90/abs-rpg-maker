#==============================================================================
# Game_Switches
#------------------------------------------------------------------------------
# Esta é a classe em que se configuram os Switches.
# Esta classe pode ser chamada utilizando $game_switches
#==============================================================================

class Game_Switches
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    @data = []
  end
  
  #--------------------------------------------------------------------------
  # Utilização de Switch
  #
  #     switch_id : ID do switch
  #--------------------------------------------------------------------------
  
  def [](switch_id)
    if switch_id <= 5000 and @data[switch_id] != nil
      return @data[switch_id]
    else
      return false
    end
  end
  
  #--------------------------------------------------------------------------
  # Opções de Switch
  #
  #     switch_id : ID do switch
  #     value     : ON (Ligado/Verdadeiro) / OFF (Desligado/Falso)
  #--------------------------------------------------------------------------
  
  def []=(switch_id, value)
    if switch_id <= 5000
      @data[switch_id] = value
    end
  end
end
