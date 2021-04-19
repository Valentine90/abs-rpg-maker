#==============================================================================
# Game_CommonEvent
#------------------------------------------------------------------------------
# Esta classe engloba os Eventos Comuns. Isto inclui a execução dos Eventos de 
# Processos Paralelos. Esta classe é usada em conjunto com a classe $game_map.
#==============================================================================

class Game_CommonEvent
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     common_event_id : ID do Evento Comum
  #--------------------------------------------------------------------------
  
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Definição do Nome
  #--------------------------------------------------------------------------
  
  def name
    return $data_common_events[@common_event_id].name
  end
  
  #--------------------------------------------------------------------------
  # Definição da Condição de Inicialização
  #--------------------------------------------------------------------------
  
  def trigger
    return $data_common_events[@common_event_id].trigger
  end
  
  #--------------------------------------------------------------------------
  # Selecionar ID do Switch da Condição de Inicialização
  #--------------------------------------------------------------------------
  
  def switch_id
    return $data_common_events[@common_event_id].switch_id
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Lista de Eventos Comuns
  #--------------------------------------------------------------------------
  
  def list
    return $data_common_events[@common_event_id].list
  end
  
  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  
  def refresh
    # Aqui é criado um interpretador para o Processo Paralelo caso necessite
    if self.trigger == 2 and $game_switches[self.switch_id] == true
      if @interpreter == nil
        @interpreter = Interpreter.new
      end
    else
      @interpreter = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Aqui é verificada a validade do Processo Paralelo
    if @interpreter != nil
      # Aqui é verificada a execução do Processo Paralelo
      unless @interpreter.running?
        # Neste comando o evento é configurado
        @interpreter.setup(self.list, 0)
      end
      # E aqui o interpretador é atualizado
      @interpreter.update
    end
  end
end
