#==============================================================================
# Interpreter (Parte 3)
#------------------------------------------------------------------------------
# É a classe que interpreta os comandos de eventos do jogo.
# É usada dentro da classe Game_Event e Game_System.
#==============================================================================

class Interpreter
  
  #--------------------------------------------------------------------------
  # Mostrar Mensagem
  #--------------------------------------------------------------------------
  
  def command_101
    # Se outro texto for configurado para message_text
    if $game_temp.message_text != nil
      # Fim
      return false
    end
    # Uma flag e uma chamada são configuradas durante o término da mensagem
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Definir a mensagem de texto na primeira linha
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    # Loop
    loop do
      # Se o próximo comando de evento for na segunda linha ou depois
      if @list[@index+1].code == 401
        # Adicionar segunda linha ou que tiver depois para message_text
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      # Se o comando de evento não estiver na segunda linha ou depois
      else
        # Se o próximo comando de evento são escolhas
        if @list[@index+1].code == 102
          # Quando uma escolha é estável na tela
          if @list[@index+1].parameters[0].size <= 4 - line_count
            # Avançar índice
            @index += 1
            # Configuração das escolhas
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        # Se o próximo evento de comando for uma entrada numérica
        elsif @list[@index+1].code == 103
          # Quando uma entrada numérica é estável na tela 
          if line_count < 4
            # Avançar índice
            @index += 1
            # Configuração da entrada numérica
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        # Continuar
        return true
      end
      # Avançar índice
      @index += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # Mostrar Escolhas
  #--------------------------------------------------------------------------
  
  def command_102
    # Se o texto for definido para message_text
    if $game_temp.message_text != nil
      # End
      return false
    end
    # Uma flag e uma chamada são configuradas durante o término da mensagem
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Configuração das escolhas
    $game_temp.message_text = ""
    $game_temp.choice_start = 0
    setup_choices(@parameters)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # No Caso de [**]
  #--------------------------------------------------------------------------
  
  def command_402
    # Quando a escolha correspondente é escolhida
    if @branch[@list[@index].indent] == @parameters[0]
      # Deletar dados da ramificação
      @branch.delete(@list[@index].indent)
      # Continuar
      return true
    end
    # Se não se coincidir com a condição: comando skip
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # No caso de Cancelamento
  #--------------------------------------------------------------------------
  
  def command_403
    # Se as escolhas forem canceladas
    if @branch[@list[@index].indent] == 4
      # Deletar dados da ramificação
      @branch.delete(@list[@index].indent)
      # Continuar
      return true
    end
    # Se não se coincidir com a condição: comando skip
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # Armazenar Número
  #--------------------------------------------------------------------------
  
  def command_103
    # Se o texto for definido para message_text
    if $game_temp.message_text != nil
      # Fim
      return false
    end
    # Uma flag e uma chamada são configuradas durante o término da mensagem
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Configuração de uma entrada numérica
    $game_temp.message_text = ""
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = @parameters[0]
    $game_temp.num_input_digits_max = @parameters[1]
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opções de Mensagem
  #--------------------------------------------------------------------------
  
  def command_104
    # Se a mensagem está sendo exibida
    if $game_temp.message_window_showing
      # Fim
      return false
    end
    # Mudar cada opção
    $game_system.message_position = @parameters[0]
    $game_system.message_frame = @parameters[1]
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Definir Teclas
  #--------------------------------------------------------------------------
  
  def command_105
    # Definir ID da variável para a entrada de tecla
    @button_input_variable_id = @parameters[0]
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Espera
  #--------------------------------------------------------------------------
  
  def command_106
    # Definir o tamanho da espera
    @wait_count = @parameters[0] * 2
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Condições
  #--------------------------------------------------------------------------
  
  def command_111
    # Iniciar variável local
    result = false
    case @parameters[0]
    when 0  # Switch
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  # Variável
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      # Aqui se definem os casos para as variáveis
      case @parameters[4]
      when 0  # value1 for igual ao value2
        result = (value1 == value2)
      when 1  # value1 for maior ou igual ao value2
        result = (value1 >= value2)
      when 2  # value1 for menor ou igual ao value2
        result = (value1 <= value2)
      when 3  # value1 for maior que o value2
        result = (value1 > value2)
      when 4  # value1 for menor que o value2
        result = (value1 < value2)
      when 5  # value1 não for igual ao value2
        result = (value1 != value2)
      end
    when 2  # Switch Local
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # Temporizador
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4  # Aqui se definem os casos para Herói
      actor = $game_actors[@parameters[1]]
      if actor != nil
        case @parameters[2]
        when 0  # Se está no grupo
          result = ($game_party.actors.include?(actor))
        when 1  # Nome
          result = (actor.name == @parameters[3])
        when 2  # Habilidade
          result = (actor.skill_learn?(@parameters[3]))
        when 3  # Arma
          result = (actor.weapon_id == @parameters[3])
        when 4  # Armadura
          result = (actor.armor1_id == @parameters[3] or
                    actor.armor2_id == @parameters[3] or
                    actor.armor3_id == @parameters[3] or
                    actor.armor4_id == @parameters[3])
        when 5  # Status
          result = (actor.state?(@parameters[3]))
        end
      end
    when 5  # Inimigo
      enemy = $game_troop.enemies[@parameters[1]]
      if enemy != nil
        case @parameters[2]
        when 0  # Apareceu
          result = (enemy.exist?)
        when 1  # Status
          result = (enemy.state?(@parameters[3]))
        end
      end
    when 6  # Herói
      character = get_character(@parameters[1])
      if character != nil
        result = (character.direction == @parameters[2])
      end
    when 7  # Ouro
      if @parameters[2] == 0
        result = ($game_party.gold >= @parameters[1])
      else
        result = ($game_party.gold <= @parameters[1])
      end
    when 8  # Item
      result = ($game_party.item_number(@parameters[1]) > 0)
    when 9  # Arma
      result = ($game_party.weapon_number(@parameters[1]) > 0)
    when 10  # Armadura
      result = ($game_party.armor_number(@parameters[1]) > 0)
    when 11  # Tecla
      result = (Input.press?(@parameters[1]))
    when 12  # Script
      result = eval(@parameters[1])
    end
    # Uma determinante é armazenada em partes
    @branch[@list[@index].indent] = result
    # Se o resultado da determinante for verdadeiro
    if @branch[@list[@index].indent] == true
      # Deletar dados da ramificação
      @branch.delete(@list[@index].indent)
      # Continuar
      return true
    end
    # Se não se coincidir com a condição: comando skip
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # Excessão
  #--------------------------------------------------------------------------
  
  def command_411
    # Se o resultado da determinate for falso
    if @branch[@list[@index].indent] == false
      # Deletar os dados da ramificação
      @branch.delete(@list[@index].indent)
      # Continuar
      return true
    end
    # Se não se coincidir com a condição: comando skip
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # Ciclo
  #--------------------------------------------------------------------------
  
  def command_112
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Repetição
  #--------------------------------------------------------------------------
  
  def command_413
    # Selecionar o alinhamento
    indent = @list[@index].indent
    # Loop
    loop do
      # Retornar índice
      @index -= 1
      # Se o comando de evento for do mesmo nível que o evento anterior
      if @list[@index].indent == indent
        # Continuar
        return true
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Romper Ciclo
  #--------------------------------------------------------------------------
  
    def command_113
    # Selecionar evento
    indent = @list[@index].indent
    # Copiar índice para as variáveis temporárias
    temp_index = @index
    # Loop
    loop do
      # Avançar índice
      temp_index += 1
      # Se um ajuste de Loop não for encontrado
      if temp_index >= @list.size-1
        # Continuar
        return true
      end
      # Este comando de evento [repetição] E o evento é superficial
      if @list[temp_index].code == 413 and @list[temp_index].indent < indent
        # Atualizar índice
        @index = temp_index
        # Continuar
        return true
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Parar Evento
  #--------------------------------------------------------------------------
  
  def command_115
    # Fim do evento
    command_end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Apagar Evento Temporário
  #--------------------------------------------------------------------------
  
  def command_116
    # Se o ID do evento for válido
    if @event_id > 0
      # Apagar evento
      $game_map.events[@event_id].erase
    end
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Evento Comum
  #--------------------------------------------------------------------------
  
  def command_117
    # Selecionar o evento comum
    common_event = $data_common_events[@parameters[0]]
    # Aqui é verificada a validade do evento comum
    if common_event != nil
      # Um sub-interpretador é criado
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Label
  #--------------------------------------------------------------------------
  
  def command_118
    # Continue
    return true
  end
  
  #--------------------------------------------------------------------------
  # Ir Para Label
  #--------------------------------------------------------------------------
  
  def command_119
    # Selecionar nome de label
    label_name = @parameters[0]
    # inicializar variáveis temporárias
    temp_index = 0
    # Loop
    loop do
      # Se um ajuste de label não for encontrado
      if temp_index >= @list.size-1
        # Continuar
        return true
      end
      # Se o comando de evento for um label designado
      if @list[temp_index].code == 118 and
         @list[temp_index].parameters[0] == label_name
        # Avançar índice
        @index = temp_index
        # Continuar
        return true
      end
      # Avançar índice
      temp_index += 1
    end
  end
end
