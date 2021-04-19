#==============================================================================
# Game_Variables
#------------------------------------------------------------------------------
# Esta é a classe em que se configuram as Variáveis.
# Esta classe pode ser chamada utilizando $game_variables
#==============================================================================

class Game_Variables
 
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
 
  def initialize
    @data = []
  end
 
  #--------------------------------------------------------------------------
  # Utilização das Variáveis
  #
  #     variable_id : ID da variável
  #--------------------------------------------------------------------------
 
  def [](variable_id)
    if variable_id <= 5000 and @data[variable_id] != nil
      return @data[variable_id]
    else
      return 0
    end
  end

  #--------------------------------------------------------------------------
  # Opções de Variável
  #
  #     variable_id : ID da variável
  #     value       : valor numérico, ou representativo da variável
  #--------------------------------------------------------------------------
 
  def []=(variable_id, value)
    if variable_id <= 5000
      @data[variable_id] = value
    end
  end
end
