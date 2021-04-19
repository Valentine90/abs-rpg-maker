#==============================================================================
# Interpreter (Parte 6)
#------------------------------------------------------------------------------
# É a classe que interpreta os comandos de eventos do jogo.
# É usada dentro da classe Game_Event e Game_System.
#==============================================================================

class Interpreter
  
  #--------------------------------------------------------------------------
  # Inserir Batalha
  #--------------------------------------------------------------------------
  
  def command_301
    # Se não forem Grupos de Inimigos Inválidos
    if $data_troops[@parameters[0]] != nil
      # Definir flag de parada de batalha
      $game_temp.battle_abort = true
      # Definir flag de chamada de batalha
      $game_temp.battle_calling = true
      $game_temp.battle_troop_id = @parameters[0]
      $game_temp.battle_can_escape = @parameters[1]
      $game_temp.battle_can_lose = @parameters[2]
      # Definir chamada
      current_indent = @list[@index].indent
      $game_temp.battle_proc = Proc.new { |n| @branch[current_indent] = n }
    end
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Se Vencer
  #--------------------------------------------------------------------------
  
  def command_601
    # Quando o resultado da batalha for a vitória
    if @branch[@list[@index].indent] == 0
      # Deletar dados de ramificação
      @branch.delete(@list[@index].indent)
      # Continuar
      return true
    end
    # Se não se coincidir com a condição: comando skip
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # Se Fugir
  #--------------------------------------------------------------------------
  
  def command_602
    # Quando o resultado da batalha for uma fuga
    if @branch[@list[@index].indent] == 1
      # Deletar dados de ramificação
      @branch.delete(@list[@index].indent)
      # Continuar
      return true
    end
    # Se não se coincidir com a condição: comando skip
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # Se Perder
  #--------------------------------------------------------------------------
  
  def command_603
    # Quando o resultado da batalha for a derrota
    if @branch[@list[@index].indent] == 2
      # Deletar dados de ramificação
      @branch.delete(@list[@index].indent)
      # Continuar
      return true
    end
    # Se não se coincidir com a condição: comando skip
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # Inserir Loja
  #--------------------------------------------------------------------------
  
  def command_302
    # Definir flag de parada de batalha
    $game_temp.battle_abort = true
    # Definir flag de chamada de batalha
    $game_temp.shop_calling = true
    # Definir lista de Itens da loja
    $game_temp.shop_goods = [@parameters]
    # Loop
    loop do
      # Avançar índice
      @index += 1
      # Se o próximo comando de evento tiver uma loja na segunda linha ou depois
      if @list[@index].code == 605
        # Adicionar Itens na lista da loja
        $game_temp.shop_goods.push(@list[@index].parameters)
      # Se o próximo comando de evento não tiver uma loja na segunda linha ou 
      # depois
      else
        # Fim
        return false
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Inserir Nome do Herói
  #--------------------------------------------------------------------------
  
  def command_303
    # Se não forem Heróis inválidos
    if $data_actors[@parameters[0]] != nil
      # Definir flag de parada de batalha
      $game_temp.battle_abort = true
      # Definir flag de entrada de nome
      $game_temp.name_calling = true
      $game_temp.name_actor_id = @parameters[0]
      $game_temp.name_max_char = @parameters[1]
    end
    # Avançar índice
    @index += 1
    # Fim
    return false
  end
  
  #--------------------------------------------------------------------------
  # Mudar HP
  #--------------------------------------------------------------------------
  
  def command_311
    # Selecionar valor
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Processo com iterador
    iterate_actor(@parameters[0]) do |actor|
      # Se o HP não for 0
      if actor.hp > 0
        # Mudar HP (Se não for permitido morrer tornar o HP=1)
        if @parameters[4] == false and actor.hp + value <= 0
          actor.hp = 1
        else
          actor.hp += value
        end
      end
    end
    # Determinar game over
    $game_temp.gameover = $game_party.all_dead?
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar MP
  #--------------------------------------------------------------------------
  
  def command_312
    # Selecionar valor
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Processo com iterador
    iterate_actor(@parameters[0]) do |actor|
      # Mudar MP do Herói
      actor.sp += value
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Status
  #--------------------------------------------------------------------------
  
  def command_313
    # Processo com iterador
    iterate_actor(@parameters[0]) do |actor|
      # Mudar Status
      if @parameters[1] == 0
        actor.add_state(@parameters[2])
      else
        actor.remove_state(@parameters[2])
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Curar Tudo
  #--------------------------------------------------------------------------
  
  def command_314
    # Processo com iterador
    iterate_actor(@parameters[0]) do |actor|
      # Curar tudo para o Herói
      actor.recover_all
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar EXP
  #--------------------------------------------------------------------------
  
  def command_315
    # Selecionar valor
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Processo com iterador
    iterate_actor(@parameters[0]) do |actor|
      # Mudar EXP do Herói
      actor.exp += value
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Nível
  #--------------------------------------------------------------------------
  
  def command_316
    # Selecionar valor
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Processo com iterador
    iterate_actor(@parameters[0]) do |actor|
      # Mudar Nível do Herói
      actor.level += value
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Parâmetros
  #--------------------------------------------------------------------------
  
  def command_317
    # Selecionar valor
    value = operate_value(@parameters[2], @parameters[3], @parameters[4])
    # Selecionar Herói
    actor = $game_actors[@parameters[0]]
    # Mudar parâmetros
    if actor != nil
      case @parameters[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxMP
        actor.maxsp += value
      when 2  # Força
        actor.str += value
      when 3  # Destreza
        actor.dex += value
      when 4  # Agilidade
        actor.agi += value
      when 5  # Magia
        actor.int += value
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Habilidades
  #--------------------------------------------------------------------------
  
  def command_318
    # Selecionar Herói
    actor = $game_actors[@parameters[0]]
    # Mudar Habilidade
    if actor != nil
      if @parameters[1] == 0
        actor.learn_skill(@parameters[2])
      else
        actor.forget_skill(@parameters[2])
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Equipamento
  #--------------------------------------------------------------------------
  
  def command_319
    # Selecionar Herói
    actor = $game_actors[@parameters[0]]
    # Mudar Equipamento
    if actor != nil
      actor.equip(@parameters[1], @parameters[2])
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Nome do Herói
  #--------------------------------------------------------------------------
  
  def command_320
    # Selecionar Herói
    actor = $game_actors[@parameters[0]]
    # Mudar nome
    if actor != nil
      actor.name = @parameters[1]
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Classe
  #--------------------------------------------------------------------------
  
  def command_321
    # Selecionar Herói
    actor = $game_actors[@parameters[0]]
    # Mudar Clase
    if actor != nil
      actor.class_id = @parameters[1]
    end
    # Continuae
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Gráfico do Herói
  #--------------------------------------------------------------------------
  
  def command_322
    # Selecionar Herói
    actor = $game_actors[@parameters[0]]
    # Mudar gráfico
    if actor != nil
      actor.set_graphic(@parameters[1], @parameters[2],
        @parameters[3], @parameters[4])
    end
    # Atualizar Jogaador
    $game_player.refresh
    # Continuar
    return true
  end
end
