#==============================================================================
# Game_Battler (Parte 2)
#------------------------------------------------------------------------------
# Esta classe considera os jogadores da batalha.
# Esta classe identifica os Aliados ou Heróis como (Game_Actor) e
# os Inimigos como (Game_Enemy).
#==============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  # Verificação do Status
  #
  #     state_id : ID do status
  #--------------------------------------------------------------------------
  
  def state?(state_id)
    # Se o status correspondete for incluído colocar ON/Verdadeiro
    return @states.include?(state_id)
  end
  
  #--------------------------------------------------------------------------
  # Se os Verificadores Estiverem Cheios
  #
  #     state_id : ID do status
  #--------------------------------------------------------------------------
  
  def state_full?(state_id)
    # Se o status correspondete for incluído colocar OFF/Falso
    unless self.state?(state_id)
      return false
    end
    # retornar a ON no primeiro caso
    if @states_turn[state_id] == -1
      return true
    end
    # Se o número de turnos automáticos for igual ao número de turnos mínimos.
    # Tornar ON
    return @states_turn[state_id] == $data_states[state_id].hold_turn
  end
  
  #--------------------------------------------------------------------------
  # Uso do Status
  #
  #     state_id : ID do status
  #     force    : Flag compulsiva
  #--------------------------------------------------------------------------
  
  def add_state(state_id, force = false)
    # Se for um status inválido
    if $data_states[state_id] == nil
      # Fim
      return
    end
    # Quando não for compulsivo
    unless force
      # Loop de Estado existente
      for i in @states
        # Trocar de status com o novo status existente
        # Verificar possibilidade de aplicação de status
        if $data_states[i].minus_state_set.include?(state_id) and
           not $data_states[state_id].minus_state_set.include?(i)
          # Fim
          return
        end
      end
    end
    # Quando não se ganham status
    unless state?(state_id)
      # ID do status que foi incluído
      @states.push(state_id)
      # Se for efetivo, em caso de HP 0
      if $data_states[state_id].zero_hp
        # Trocar o HP para 0
        @hp = 0
      end
      # Loop de todos os status
      for i in 1...$data_states.size
        # Troca de status (+)
        if $data_states[state_id].plus_state_set.include?(i)
          add_state(i)
        end
        # Troca de Status (-)
        if $data_states[state_id].minus_state_set.include?(i)
          remove_state(i)
        end
      end
      # Sorteio de um status aleatório
      @states.sort! do |a, b|
        state_a = $data_states[a]
        state_b = $data_states[b]
        if state_a.rating > state_b.rating
          -1
        elsif state_a.rating < state_b.rating
          +1
        elsif state_a.restriction > state_b.restriction
          -1
        elsif state_a.restriction < state_b.restriction
          +1
        else
          a <=> b
        end
      end
    end
    # Se for compulsivo
    if force
      # Número de turnos de aplicação do efeito (-1 Inválido)
      @states_turn[state_id] = -1
    end
    # Se for compulsivo
    unless @states_turn[state_id] == -1
      # Número de turnos de aplicação do efeito escolhido
      @states_turn[state_id] = $data_states[state_id].hold_turn
    end
    # Se for impossível
    unless movable?
      # Esvaziar ação
      @current_action.clear
    end
    # Localizar o HP e MP máximo
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  
  #--------------------------------------------------------------------------
  # Fim do Status
  #
  #     state_id : ID do Status
  #     force    : Flag Compulsiva
  #--------------------------------------------------------------------------
  
  def remove_state(state_id, force = false)
    # Quando o efeito do status acaba
    if state?(state_id)
      # Quando o status for removido
      if @states_turn[state_id] == -1 and not force
        # Fim
        return
      end
      # Se considera status de HP 0.
      if @hp == 0 and $data_states[state_id].zero_hp
        # Se não, se considera outro status
        zero_hp = false
        for i in @states
          if i != state_id and $data_states[i].zero_hp
            zero_hp = true
          end
        end
        # Se o HP não for 0, troca-se o HP para 1
        if zero_hp == false
          @hp = 1
        end
      end
      # O ID do status e o seu número de turnos são deletados
      @states.delete(state_id)
      @states_turn.delete(state_id)
    end
    # Localiza o HP e o MP máximo
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  
  #--------------------------------------------------------------------------
  # Usar Animação do Status
  #--------------------------------------------------------------------------
  
  def state_animation_id
    # Quando um status não se aplica
    if @states.size == 0
      return 0
    end
    # A animação do status é devolvida
    return $data_states[@states[0]].animation_id
  end
  
  #--------------------------------------------------------------------------
  # Definição de Restrições
  #--------------------------------------------------------------------------
  
  def restriction
    restriction_max = 0
    # Status de restrição máxima
    for i in @states
      if $data_states[i].restriction >= restriction_max
        restriction_max = $data_states[i].restriction
      end
    end
    return restriction_max
  end
  
  #--------------------------------------------------------------------------
  # Verificar se pode Ganhar EXP
  #--------------------------------------------------------------------------
  
  def cant_get_exp?
    for i in @states
      if $data_states[i].cant_get_exp
        return true
      end
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Verificação de status de Ataque Inevitável
  #--------------------------------------------------------------------------
  
  def cant_evade?
    for i in @states
      if $data_states[i].cant_evade
        return true
      end
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Verificação do Status do Dano
  #--------------------------------------------------------------------------
  
  def slip_damage?
    for i in @states
      if $data_states[i].slip_damage
        return true
      end
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Remoção dos Status ao Fim da Batalha
  #--------------------------------------------------------------------------
  
  def remove_states_battle
    for i in @states.clone
      if $data_states[i].battle_only
        remove_state(i)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Verificar se não é Necessária a Remoção do Status pelo Número de Turnos
  #--------------------------------------------------------------------------
  
  def remove_states_auto
    for i in @states_turn.keys.clone
      if @states_turn[i] > 0
        @states_turn[i] -= 1
      elsif rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Remoção do Status de Choque a cada Ataque Psíquico
  #--------------------------------------------------------------------------
  
  def remove_states_shock
    for i in @states.clone
      if rand(100) < $data_states[i].shock_release_prob
        remove_state(i)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Aplicar Troca de Status (+)
  #
  #     plus_state_set  : Trocar Status (+)
  #--------------------------------------------------------------------------
  
  def states_plus(plus_state_set)
    # Esvaziar Flag de efeito
    effective = false
    # Loop do Status a remover
    for i in plus_state_set
      # Quando o status não é definido
      unless self.state_guard?(i)
        # Uma Flag de efeito é aplicado se o status não é cheio
        effective |= self.state_full?(i) == false
        # Status sem resistência
        if $data_states[i].nonresistance
          # Aplicar flag de troca de Status
          @state_changed = true
          # Remover Status
          add_state(i)
        # Qunado o Status não estiver cheio
        elsif self.state_full?(i) == false
          # O grau de Status é sorteado entre a possibilidades
          if rand(100) < [0,100,80,60,40,20,0][self.state_ranks[i]]
            # Aplicar Flag de troca de Status
            @state_changed = true
            # remover Status
            add_state(i)
          end
        end
      end
    end
    # Fim
    return effective
  end
  
  #--------------------------------------------------------------------------
  # Aplicar Troca de Status (-)
  #
  #     minus_state_set  : trocar Status (-)
  #--------------------------------------------------------------------------
  def states_minus(minus_state_set)
    # Esvaziar Flag de efeito
    effective = false
    # Loop do Status a remover
    for i in minus_state_set
      # Uma Flag de efeito se inclúi no status
      effective |= self.state?(i)
      # Aplicar Flag de troca de Status
      @state_changed = true
      # Apagar Status
      remove_state(i)
    end
    # Fim
    return effective
  end
end
