#==============================================================================
# Game_SelfSwitches
#------------------------------------------------------------------------------
# Esta é a classe em que se configuram os Switches Locais
# Esta classe pode ser chamada utilizando $game_selfswitches
#==============================================================================

class Game_SelfSwitches
 
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
 
  def initialize
    @data = {}
  end
 
  #--------------------------------------------------------------------------
  # Utilização de Switch Local
  #
  #     key : chave
  #--------------------------------------------------------------------------
 
  def [](key)
    return @data[key] == true ? true : false
  end
 
  #--------------------------------------------------------------------------
  # Opções de Switch Local
  #
  #     key   : chave
  #     value : ON (Ligado/Verdadeiro) / OFF (Desligado/Falso)
  #--------------------------------------------------------------------------
 
  def []=(key, value)
    @data[key] = value
  end
end
