#==============================================================================
# Game_Battler (Parte 3)
#------------------------------------------------------------------------------
# Esta classe considera os jogadores da batalha.
# Esta classe identifica os Aliados ou Heróis como (Game_Actor) e
# os Inimigos como (Game_Enemy).
#==============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  # Verificação da Habilidade
  #
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  
  def skill_can_use?(skill_id)
    # Seu uso é impossível se não tem MP suficiente
    if $data_skills[skill_id].sp_cost > self.sp
      return false
    end
    # Seu uso é impossível se estiver morto
    if dead?
      return false
    end
    # Se estiver com o status mudo também não é possível utilizar a habilidade
    if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
      return false
    end
    # Definição do tempo de uso
    occasion = $data_skills[skill_id].occasion
    # Se está em batalha
    if $game_temp.in_battle
      # Sempre ou somente em Batalha
      return (occasion == 0 or occasion == 1)
    # Quando não está em batalha
    else
      # Sempre ou somente em Menu
      return (occasion == 0 or occasion == 2)
    end
  end
  
  #--------------------------------------------------------------------------
  # Aplicar o Efeito de um Ataque
  #
  #     attacker : Atacante
  #--------------------------------------------------------------------------
  
  def attack_effect(attacker)
    # Esvaziar a flag de ataque crítico
    self.critical = false
    # Verificação do primeiro ataque
    hit_result = (rand(100) < attacker.hit)
    # Em caso de ataque á distância
    if hit_result == true
      # Cálculo ddos danos básicos
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      # Calcular atributo
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      # Se o dano for positivo
      if self.damage > 0
        # Calcular dano crítico
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        # calcular defesa
        if self.guarding?
          self.damage /= 2
        end
      end
      # Aplicar dano
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Se for dano duplicado
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    # Caso de ataque á distância
    if hit_result == true
      # Aplicar dano se for choque
      remove_states_shock
      # Subtrair dano do HP
      self.hp -= self.damage
      # Trocar status
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # Se houver falha
    else
      # Ao tentar o ataque, exibir a palavra...
      self.damage = "Errou!"
      # Esvaziar a Flag de ataque crítico
      self.critical = false
    end
    # Fim
    return true
  end
  
  #--------------------------------------------------------------------------
  # Aplicar o Efeito da Habilidade
  #
  #     user  : Jogador que utiliza a Habilidade
  #     skill : Habilidade
  #--------------------------------------------------------------------------
  
  def skill_effect(user, skill)
    # Esvaziar a Flag de ataque crítico
    self.critical = false
    # O alcance da Habilidade é um aliado com 1 de HP
    # Ou efeito da Habilidade em um aliado de HP 0.
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      # Fim
      return false
    end
    # Esvaziar Flag de efeito
    effective = false
    # Flag de efeito quanto houver um evento comum
    effective |= skill.common_event_id > 0
    # Verificar o primeiro ataque
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    # Se a Habilidade não for efetiva
    effective |= hit < 100
    # Se acertar
    if hit_result == true
      # Cálculo do Dano
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # Calcular amplificação
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      # Cálculo do dano básico
      self.damage = power * rate / 20
      # Correccion de Atributo
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      # Quando o dano for positivo
      if self.damage > 0
        # Calcular defesa
        if self.guarding?
          self.damage /= 2
        end
      end
      # Aplicação do dano
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Verificar segundo ataque
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # Se a Habilidade não for efetiva
      effective |= hit < 100
    end
    # Se acertar
    if hit_result == true
      # Força
      if skill.power != 0 and skill.atk_f > 0
        # Aplicação do status de choque
        remove_states_shock
        # Aplicar Flag de efeito
        effective = true
      end
      # Subtrair dano do HP
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      # Troca de status
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      # Se a Força for 0
      if skill.power == 0
        # Uma sequencia de caracteres vazios é exibida como dano
        self.damage = ""
        # Quando o status não é alterado
        unless @state_changed
          # Ao errar exibir...
          self.damage = "Errou!"
        end
      end
    # Em caso de Erro
    else
      # Ao errar exibir...
      self.damage = "Errou!"
    end
    # Quando não se está em batalha
    unless $game_temp.in_battle
      # Ao errar não colocar nada
      self.damage = nil
    end
    # Fim
    return effective
  end
  
  #--------------------------------------------------------------------------
  # Aplicação do Efeito de um Item
  #
  #     item : Item
  #--------------------------------------------------------------------------
  
  def item_effect(item)
    # Esvaziar a Flag de ataque crítico
    self.critical = false
    # O alcance da Habilidade é um aliado com 1 de HP
    # Ou efeito da Habilidade em um aliado de HP 0.
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      # Fim
      return false
    end
    # Esvaziar a Flag de efeito
    effective = false
    # Esvaziar a Flag de efeito quando houver um Evento Comum
    effective |= item.common_event_id > 0
    # Verificar se for um ataque à distância
    hit_result = (rand(100) < item.hit)
    # Se a Habilidade não for efetiva
    effective |= item.hit < 100
    # Se acertar
    if hit_result == true
      # Cálculo da quantidade a se recuperar
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
      # Cálculo do atributo
      recover_hp *= elements_correct(item.element_set)
      recover_hp /= 100
      recover_sp *= elements_correct(item.element_set)
      recover_sp /= 100
      # Aplicação da cura
      if item.variance > 0 and recover_hp.abs > 0
        amp = [recover_hp.abs * item.variance / 100, 1].max
        recover_hp += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and recover_sp.abs > 0
        amp = [recover_sp.abs * item.variance / 100, 1].max
        recover_sp += rand(amp+1) + rand(amp+1) - amp
      end
      # Se a quantidade a se recuperar for menor do que 0
      if recover_hp < 0
        # Calcular defesa
        if self.guarding?
          recover_hp /= 2
        end
      end
      # A recuperação de MP se inverte e é fixa como o valor do dano
      self.damage = -recover_hp
      # Localizar HP. Recuperar MP
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      # Troca de Status
      @state_changed = false
      effective |= states_plus(item.plus_state_set)
      effective |= states_minus(item.minus_state_set)
      # Se o parâmetro for existente
      if item.parameter_type > 0 and item.parameter_points != 0
        # Parâmetros
        case item.parameter_type
        when 1  # MaxHP
          @maxhp_plus += item.parameter_points
        when 2  # MaxMP
          @maxsp_plus += item.parameter_points
        when 3  # Força
          @str_plus += item.parameter_points
        when 4  # Destreza
          @dex_plus += item.parameter_points
        when 5  # Agilidade
          @agi_plus += item.parameter_points
        when 6  # Magia
          @int_plus += item.parameter_points
        end
        # Aplicar Flag de efeito
        effective = true
      end
      # Proporção de recuperação de HP
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        # Uma seqüência de caracteres é exibida como dano
        self.damage = ""
        # Proporção de recuperação de MP
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # Quando trocar de status
          unless @state_changed
            # Ao errar exibir...
            self.damage = "Errou!"
          end
        end
      end
    # Se errar
    else
      # Ao errar exibir...
      self.damage = "Errou!"
    end
    # Quando não estiver em batalha
    unless $game_temp.in_battle
      # Ao errar não colocar nada
      self.damage = nil
    end
    # Fim
    return effective
  end
  
  #--------------------------------------------------------------------------
  # Aplicação do Comando Receber Dano
  #--------------------------------------------------------------------------
  
  def slip_damage_effect
    # Aplicar dano
    self.damage = self.maxhp / 10
    # Aplicação
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    # Dano subtraído do HP
    self.hp -= self.damage
    # Fim
    return true
  end
  
  #--------------------------------------------------------------------------
  # Cálculo do Dano do Atributo
  #
  #     element_set : atributo
  #--------------------------------------------------------------------------
  
  def elements_correct(element_set)
    # Se não for atributo
    if element_set == []
      # Devolver 100
      return 100
    end
    # Aplicar no mais fraco pelo atributo
    # o método element_rate é ramificação da classe Game_Actor
    # Define a classe Game_Enemy
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end
