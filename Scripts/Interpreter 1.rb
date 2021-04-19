#==============================================================================
# Interpreter (Parte 1)
#------------------------------------------------------------------------------
# É a classe que interpreta os comandos de eventos do jogo.
# É usada dentro da classe Game_Event e Game_System.
#==============================================================================

class Interpreter
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     depth : Limite
  #     main  : Bandeira principal
  #--------------------------------------------------------------------------
  
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    # Se chegar ao limite de 100
    if depth > 100
      print("A chamada de Eventos Comuns excedeu o limite.")
      exit
    end
    # Limpa o estado dos comandos de classe
    clear
  end
  
  #--------------------------------------------------------------------------
  # Limpar
  #--------------------------------------------------------------------------
  
  def clear
    @map_id = 0                       # ID do mapa
    @event_id = 0                     # ID do evento
    @message_waiting = false          # Esperando o término da mensagem
    @move_route_waiting = false       # Esperando o término de um movimento
    @button_input_variable_id = 0     # Entrada do ID da variável da tecla
    @wait_count = 0                   # Contagem do peso
    @child_interpreter = nil          # Interpretador filho
    @branch = {}                      # Dados do interpretador filho
  end
  
  #--------------------------------------------------------------------------
  # Configurando um Evento
  #
  #     list     : Lista de execução
  #     event_id : ID do evento
  #--------------------------------------------------------------------------
  
  def setup(list, event_id)
    #Limpa o estado dos comandos de classe
    clear
    # ID do mapa é memorizada
    @map_id = $game_map.map_id
    # ID do evento é memorizada
    @event_id = event_id
    # Lista de comandos são memorizados
    @list = list
    # Índice é inicializado
    @index = 0
    # Limpa os dados da filial
    @branch.clear
  end
  
  #--------------------------------------------------------------------------
  # Determinar Execução
  #--------------------------------------------------------------------------
  
  def running?
    return @list != nil
  end
  
  #--------------------------------------------------------------------------
  # Iniciando a configuração de um evento
  #--------------------------------------------------------------------------
  
  def setup_starting_event
    # Um mapa é atualizado se necessário
    if $game_map.need_refresh
      $game_map.refresh
    end
    # Quando a chamada de um evento comum for reservada
    if $game_temp.common_event_id > 0
      # Um evento é ajustado
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      # Reserva é cancelada
      $game_temp.common_event_id = 0
      return
    end
    # Loop (evento de mapa)
    for event in $game_map.events.values
      # Se houver um Evento ocorrendo
      if event.starting
        # Se não é uma execução automática
        if event.trigger < 3
          # Limpar flag de inicialização
          event.clear_starting
          # Trava
          event.lock
        end
        # Um evento é configurado
        setup(event.list, event.id)
        return
      end
    end
    # Loop (evento de mapa)
    for common_event in $data_common_events.compact
      # Se for Execução Automática e uma condição de switch estiver ON
      if common_event.trigger == 1 and
         $game_switches[common_event.switch_id] == true
        # Um evento é ajustado
        setup(common_event.list, 0)
        return
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização de um Frame
  #--------------------------------------------------------------------------
  
  def update
    # Um contador de loops foi inicializado
    @loop_count = 0
    # Loop
    loop do
      # Adiciona 1 no contador de loops
      @loop_count += 1
      # Comando de evento quando 100 loops são feitos
      if @loop_count > 100
        # Graphics.update é chamado para prevenção de congelamento
        Graphics.update
        @loop_count = 0
      end
      # Quando um mapa difere do tempo de inicialização do evento
      if $game_map.map_id != @map_id
        # ID do envento é tornada 0
        @event_id = 0
      end
      # Quando existe um interpretador filho
      if @child_interpreter != nil
        # Um interpretador filho é atualizado
        @child_interpreter.update
        # Quando a execução de um interpretador filho acaba
        unless @child_interpreter.running?
          # Um interpretador filho é eliminado
          @child_interpreter = nil
        end
        # Quando um interpretador filho continua existindo
        if @child_interpreter != nil
          return
        end
      end
      # No caso de espera de espera de término da mensagem
      if @message_waiting
        return
      end
      # No caso de espera de término de um movimento
      if @move_route_waiting
        # Quando a rota de movimento de um jogador for pré-definida
        if $game_player.move_route_forcing
          return
        end
        # Loop (evento de mapa)
        for event in $game_map.events.values
          # Quando a rota de movimento de um jogador for pré-definida
          if event.move_route_forcing
            return
          end
        end
        # Limpa a flag de finalização de espera de término de um movimento
        @move_route_waiting = false
      end
      # No caso de espera de entrada de tecla
      if @button_input_variable_id > 0
        # O processamento de uma entrada de tecla é feito
        input_button
        return
      end
      # No caso do Espera
      if @wait_count > 0
        # O contador é diminuído
        @wait_count -= 1
        return
      end
      # Quando existir uma batalha
      if $game_temp.forcing_battler != nil
        return
      end
      # Quando a flag de chamada de cada tela for ajustada
      if $game_temp.battle_calling or
         $game_temp.shop_calling or
         $game_temp.name_calling or
         $game_temp.menu_calling or
         $game_temp.save_calling or
         $game_temp.gameover
        return
      end
      # Quando os conteúdos da lista de execução estiver vazia
      if @list == nil
        # No caso dos eventos principais de mapa
        if @main
          # O evento que está começando é ajustado
          setup_starting_event
        end
        # Quando nada é ajustado
        if @list == nil
          return
        end
      end
      # Quando é falso, retorna o valor de um comando de evento
      if execute_command == false
        return
      end
      # Um índice é avançado
      @index += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # Entrada de Tecla
  #--------------------------------------------------------------------------
  
  def input_button
    # determinar a tecla a ser precionada
    n = 0
    for i in 1..18
      if Input.trigger?(i)
        n = i
      end
    end
    # Se a tecla for precionada
    if n > 0
      # Alterar o valor das variáveis
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      # Terminar a entrada de tecla
      @button_input_variable_id = 0
    end
  end
  
  #--------------------------------------------------------------------------
  # Configurar Escolhas
  #--------------------------------------------------------------------------
  
  def setup_choices(parameters)
    # Define choice_max como limite do número de escolhas
    $game_temp.choice_max = parameters[0].size
    # Define as escolhas em message_text
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    # Define o processo de encerramento
    $game_temp.choice_cancel_type = parameters[1]
    # Definir o retorno de chamada
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end
  
  #--------------------------------------------------------------------------
  # Interação para Heróis (O grupo de Heróis é levado em consideração)
  #
  #     parameter : Se este é acima de 1. Isto é um grupo se o ID é 0.
  #--------------------------------------------------------------------------
  
  def iterate_actor(parameter)
    # Se for o grupo inteiro
    if parameter == 0
      # Loop para todo o grupo
      for actor in $game_party.actors
        # Bloqueio de valor
        yield actor
      end
    # Se for apenas um Herói
    else
      # Selecionar Herói
      actor = $game_actors[parameter]
      # Bloqueio de valor
      yield actor if actor != nil
    end
  end
  
  #--------------------------------------------------------------------------
  # Interação para inimigos (O grupo de inimigos é levado em consideração)
  #
  #     parameter : isto é o grupo, se for maior que 0 e está num índice de -1.
  #--------------------------------------------------------------------------
  
  def iterate_enemy(parameter)
    # Se for o grupo inteiro
    if parameter == -1
      # Loop para todo o grupo
      for enemy in $game_troop.enemies
        # Bloqueio de valor
        yield enemy
      end
    # Se for apenas um inimgo
    else
      # Selecionar inimigo
      enemy = $game_troop.enemies[parameter]
      # Bloqueio de valor
      yield enemy if enemy != nil
    end
  end
  
  #--------------------------------------------------------------------------
  # Interação para batalha (o grupo de Inimigos e de Heróis é considerado)
  #
  #     parameter1 : Isto é Herói se for 0 e inimigo 1
  #     parameter2 : Isto é um grupo se for maior que 0 e está num índice de -1.
  #--------------------------------------------------------------------------
  
  def iterate_battler(parameter1, parameter2)
    # Se for inimigo
    if parameter1 == 0
      # Chamar uma interação de inimigo
      iterate_enemy(parameter2) do |enemy|
        yield enemy
      end
    # Se for ator
    else
      # Se for o grupo inteiro
      if parameter2 == -1
        # Loop para o grup inteiro
        for actor in $game_party.actors
          # Bloqueio de valor
          yield actor
        end
      # Se for apenas um ator
      else
        # Selecionar ator
        actor = $game_party.actors[parameter2]
        # Bloqueio de valor
        yield actor if actor != nil
      end
    end
  end
end
