#==============================================================================
# Game_Actor
#------------------------------------------------------------------------------
# Esta é a classe que trata dos Heróis na Batalha.
#==============================================================================

class Game_Actor < Game_Battler
 
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
 
  attr_reader   :name                     # Nome
  attr_reader   :character_name           # Nome do Herói
  attr_reader   :character_hue            # Cor do Herói
  attr_reader   :class_id                 # ID da classe
  attr_reader   :weapon_id                # ID da Arma
  attr_reader   :armor1_id                # ID do Escudo
  attr_reader   :armor2_id                # ID do Elmo
  attr_reader   :armor3_id                # ID da Armadura
  attr_reader   :armor4_id                # ID do Acessório
  attr_reader   :level                    # Nível
  attr_reader   :exp                      # Experiencia (EXP)
  attr_reader   :skills                   # Habilidades
 
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     actor_id : ID do Herói
  #--------------------------------------------------------------------------
 
  def initialize(actor_id)
    super()
    setup(actor_id)
  end
 
  #--------------------------------------------------------------------------
  # Opções
  #
  #     actor_id : ID do Herói
  #--------------------------------------------------------------------------
 
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @battler_name = actor.battler_name
    @battler_hue = actor.battler_hue
    @class_id = actor.class_id
    @weapon_id = actor.weapon_id
    @armor1_id = actor.armor1_id
    @armor2_id = actor.armor2_id
    @armor3_id = actor.armor3_id
    @armor4_id = actor.armor4_id
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    @hp = maxhp
    @sp = maxsp
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    # Uso de Habilidades
    for i in 1..@level
      for j in $data_classes[@class_id].learnings
        if j.level == i
          learn_skill(j.skill_id)
        end
      end
    end
    # Atualização automática do Status
    update_auto_state(nil, $data_armors[@armor1_id])
    update_auto_state(nil, $data_armors[@armor2_id])
    update_auto_state(nil, $data_armors[@armor3_id])
    update_auto_state(nil, $data_armors[@armor4_id])
  end
 
  #--------------------------------------------------------------------------
  # Uso do ID do Herói
  #--------------------------------------------------------------------------
 
  def id
    return @actor_id
  end
  
  #--------------------------------------------------------------------------
  # Uso do Índice de Heróis
  #--------------------------------------------------------------------------
 
  def index
    return $game_party.actors.index(self)
  end
 
  #--------------------------------------------------------------------------
  # Cálculo da Experiência (EXP)
  #--------------------------------------------------------------------------

  def make_exp_list
    actor = $data_actors[@actor_id]
    @exp_list[1] = 0
    pow_i = 2.4 + actor.exp_inflation / 100.0
    for i in 2..100
      if i > actor.final_level
        @exp_list[i] = 0
      else
        n = actor.exp_basis * ((i + 3) ** pow_i) / (5 ** pow_i)
        @exp_list[i] = @exp_list[i-1] + Integer(n)
      end
    end
  end
 
  #--------------------------------------------------------------------------
  # Cálculo sobre os Atributos
  #
  #     element_id : ID do elemento
  #--------------------------------------------------------------------------
 
  def element_rate(element_id)
    # Uso do valor numérico correspondente ao grau do atributo (A,B,C,D,E,F)
    table = [0,200,150,100,50,0,-100]
    result = table[$data_classes[@class_id].element_ranks[element_id]]
    # Dividir por 2 se há uma proteção física contra o elemento
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
      armor = $data_armors[i]
      if armor != nil and armor.guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # Dividir por 2 se há uma proteção de atributo contra o elemento
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # Cálculo final
    return result
  end
 
  #--------------------------------------------------------------------------
  # Definir Grau do Status
  #--------------------------------------------------------------------------
 
  def state_ranks
    return $data_classes[@class_id].state_ranks
  end
 
  #--------------------------------------------------------------------------
  # Verificação do Status do Defensor
  #
  #     state_id : ID do status
  #--------------------------------------------------------------------------
  
  def state_guard?(state_id)
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
      armor = $data_armors[i]
      if armor != nil
        if armor.guard_state_set.include?(state_id)
          return true
        end
      end
    end
    return false
  end
 
  #--------------------------------------------------------------------------
  # Definição de um atributo em um ataque normal
  #--------------------------------------------------------------------------
 
  def element_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.element_set : []
  end
 
  #--------------------------------------------------------------------------
  # Troca do valor do atributo em um ataque normal (+) 
  #--------------------------------------------------------------------------
 
  def plus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.plus_state_set : []
  end
 
  #--------------------------------------------------------------------------
  # Troca do valor do atributo em um ataque normal (-) 
  #--------------------------------------------------------------------------
 
  def minus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.minus_state_set : []
  end
 
  #--------------------------------------------------------------------------
  # Definição do MaxHP
  #--------------------------------------------------------------------------
 
  def maxhp
    n = [[base_maxhp + @maxhp_plus, 1].max, 9999].min
    for i in @states
      n *= $data_states[i].maxhp_rate / 100.0
    end
    n = [[Integer(n), 1].max, 9999].min
    return n
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de MaxHP
  #--------------------------------------------------------------------------
 
  def base_maxhp
    return $data_actors[@actor_id].parameters[0, @level]
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de MaxMP
  #--------------------------------------------------------------------------
 
  def base_maxsp
    return $data_actors[@actor_id].parameters[1, @level]
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Ataque
  #--------------------------------------------------------------------------
 
  def base_str
    n = $data_actors[@actor_id].parameters[2, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.str_plus : 0
    n += armor1 != nil ? armor1.str_plus : 0
    n += armor2 != nil ? armor2.str_plus : 0
    n += armor3 != nil ? armor3.str_plus : 0
    n += armor4 != nil ? armor4.str_plus : 0
    return [[n, 1].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Defesa
  #--------------------------------------------------------------------------
 
  def base_dex
    n = $data_actors[@actor_id].parameters[3, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.dex_plus : 0
    n += armor1 != nil ? armor1.dex_plus : 0
    n += armor2 != nil ? armor2.dex_plus : 0
    n += armor3 != nil ? armor3.dex_plus : 0
    n += armor4 != nil ? armor4.dex_plus : 0
    return [[n, 1].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Agilidade
  #--------------------------------------------------------------------------
 
  def base_agi
    n = $data_actors[@actor_id].parameters[4, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.agi_plus : 0
    n += armor1 != nil ? armor1.agi_plus : 0
    n += armor2 != nil ? armor2.agi_plus : 0
    n += armor3 != nil ? armor3.agi_plus : 0
    n += armor4 != nil ? armor4.agi_plus : 0
    return [[n, 1].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Inteligência
  #--------------------------------------------------------------------------
 
  def base_int
    n = $data_actors[@actor_id].parameters[5, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.int_plus : 0
    n += armor1 != nil ? armor1.int_plus : 0
    n += armor2 != nil ? armor2.int_plus : 0
    n += armor3 != nil ? armor3.int_plus : 0
    n += armor4 != nil ? armor4.int_plus : 0
    return [[n, 1].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Força
  #--------------------------------------------------------------------------
 
  def base_atk
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.atk : 0
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Defesa Física
  #--------------------------------------------------------------------------
 
  def base_pdef
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    pdef1 = weapon != nil ? weapon.pdef : 0
    pdef2 = armor1 != nil ? armor1.pdef : 0
    pdef3 = armor2 != nil ? armor2.pdef : 0
    pdef4 = armor3 != nil ? armor3.pdef : 0
    pdef5 = armor4 != nil ? armor4.pdef : 0
    return pdef1 + pdef2 + pdef3 + pdef4 + pdef5
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Defesa Mágica
  #--------------------------------------------------------------------------
 
  def base_mdef
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    mdef1 = weapon != nil ? weapon.mdef : 0
    mdef2 = armor1 != nil ? armor1.mdef : 0
    mdef3 = armor2 != nil ? armor2.mdef : 0
    mdef4 = armor3 != nil ? armor3.mdef : 0
    mdef5 = armor4 != nil ? armor4.mdef : 0
    return mdef1 + mdef2 + mdef3 + mdef4 + mdef5
  end
 
  #--------------------------------------------------------------------------
  # Definição da Base de Esquiva
  #--------------------------------------------------------------------------
 
  def base_eva
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    eva1 = armor1 != nil ? armor1.eva : 0
    eva2 = armor2 != nil ? armor2.eva : 0
    eva3 = armor3 != nil ? armor3.eva : 0
    eva4 = armor4 != nil ? armor4.eva : 0
    return eva1 + eva2 + eva3 + eva4
  end
 
  #--------------------------------------------------------------------------
  # Definição do ID da Animação do Ataque
  #--------------------------------------------------------------------------
 
  def animation1_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation1_id : 0
  end
 
  #--------------------------------------------------------------------------
  # Definição do ID da Animação do Item
  #--------------------------------------------------------------------------
 
  def animation2_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation2_id : 0
  end
 
  #--------------------------------------------------------------------------
  # Definição do Nome da Classe
  #--------------------------------------------------------------------------
 
  def class_name
    return $data_classes[@class_id].name
  end
 
  #--------------------------------------------------------------------------
  # Definição da Seqüência de Caracteres da EXP
  #--------------------------------------------------------------------------
 
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp.to_s : "-------"
  end
 
  #--------------------------------------------------------------------------
  # EXP Necessária para o Próximo Nível. 
  # 
  # Definição da Seqüência de Caracteres da EXP
  #--------------------------------------------------------------------------
 
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1].to_s : "-------"
  end
 
  #--------------------------------------------------------------------------
  # Quanto Falta de EXP para o Próximo Nível. 
  #
  # Definição da Seqüência de Caracteres da EXP
  #--------------------------------------------------------------------------
 
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp).to_s : "-------"
  end
 
  #--------------------------------------------------------------------------
  # Atualização Automática
  #
  #     old_armor : protetor removido
  #     new_armor : protetor equipado
  #--------------------------------------------------------------------------
 
  def update_auto_state(old_armor, new_armor)
    # Remove o status automático do Protetor
    if old_armor != nil and old_armor.auto_state_id != 0
      remove_state(old_armor.auto_state_id, true)
    end
    # Remove o status automático do Protetor
    if new_armor != nil and new_armor.auto_state_id != 0
      add_state(new_armor.auto_state_id, true)
    end
  end
 
  #--------------------------------------------------------------------------
  # Verificação do Equipamento Fixo
  #
  #     equip_type : tipo de equipamento
  #--------------------------------------------------------------------------
 
  def equip_fix?(equip_type)
 
    case equip_type
    when 0  # Armas
      return $data_actors[@actor_id].weapon_fix
    when 1  # Escudo
      return $data_actors[@actor_id].armor1_fix
    when 2  # Elmo
      return $data_actors[@actor_id].armor2_fix
    when 3  # Armadura
      return $data_actors[@actor_id].armor3_fix
    when 4  # Acessório
      return $data_actors[@actor_id].armor4_fix
    end
    return false
  end
 
  #--------------------------------------------------------------------------
  # Troca de Equipamento
  #
  #     equip_type : tipo de Equipamento
  #     id    : ID das Armas ou Protetores, se for 0 o Equipamento foi removido
  #--------------------------------------------------------------------------
 
  def equip(equip_type, id)
    case equip_type
    when 0  # Armas
      if id == 0 or $game_party.weapon_number(id) > 0
        $game_party.gain_weapon(@weapon_id, 1)
        @weapon_id = id
        $game_party.lose_weapon(id, 1)
      end
    when 1  # Escudo
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor1_id], $data_armors[id])
        $game_party.gain_armor(@armor1_id, 1)
        @armor1_id = id
        $game_party.lose_armor(id, 1)
      end
    when 2  # Elmo
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor2_id], $data_armors[id])
        $game_party.gain_armor(@armor2_id, 1)
        @armor2_id = id
        $game_party.lose_armor(id, 1)
      end
    when 3  # Armadura
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor3_id], $data_armors[id])
        $game_party.gain_armor(@armor3_id, 1)
        @armor3_id = id
        $game_party.lose_armor(id, 1)
      end
    when 4  # Acessório
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor4_id], $data_armors[id])
        $game_party.gain_armor(@armor4_id, 1)
        @armor4_id = id
        $game_party.lose_armor(id, 1)
      end
    end
  end
 
  #--------------------------------------------------------------------------
  # Verificação do Equipamento
  #
  #     item : Item
  #--------------------------------------------------------------------------
 
  def equippable?(item)
    # Se forem Armas
    if item.is_a?(RPG::Weapon)
      # Quando os armas estão equipadas, pode-se utilizar class_id
      if $data_classes[@class_id].weapon_set.include?(item.id)
        return true
      end
    end
    # Se forem Protetores
    if item.is_a?(RPG::Armor)
      # Quanso os protetores estão equipados, pode-se utilizar class_id
      if $data_classes[@class_id].armor_set.include?(item.id)
        return true
      end
    end
    return false
  end
 
  #--------------------------------------------------------------------------
  # Troca da EXP
  #
  #     exp : nova EXP
  #--------------------------------------------------------------------------
 
  def exp=(exp)
    @exp = [[exp, 9999999].min, 0].max
    # Melhoramento
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      @level += 1
      # Habilidades são aprendidas conforme o Nível
      for j in $data_classes[@class_id].learnings
        if j.level == @level
          learn_skill(j.skill_id)
        end
      end
    end
    # Agravante
    while @exp < @exp_list[@level]
      @level -= 1
    end
    # Aumento do HP e MP
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
 
  #--------------------------------------------------------------------------
  # Troca de Nível
  #
  #     level : novo Nível
  #--------------------------------------------------------------------------
  
  def level=(level)
    # Se a quantidade de EXP foi alcançada
    level = [[level, $data_actors[@actor_id].final_level].min, 1].max
    # Trocar EXP
    self.exp = @exp_list[level]
  end
 
  #--------------------------------------------------------------------------
  # Aprender Habilidade
  #
  #     skill_id : ID da Habilidade
  #--------------------------------------------------------------------------
 
  def learn_skill(skill_id)
    if skill_id > 0 and not skill_learn?(skill_id)
      @skills.push(skill_id)
      @skills.sort!
    end
  end
 
  #--------------------------------------------------------------------------
  # Esquecer Habilidade
  #
  #     skill_id : ID da Habilidade
  #--------------------------------------------------------------------------
 
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
 
  #--------------------------------------------------------------------------
  # Verificação da Necessidade de se Aprender a Habilidade
  #
  #     skill_id : ID da Habilidade
  #--------------------------------------------------------------------------
 
  def skill_learn?(skill_id)
    return @skills.include?(skill_id)
  end
 
  #--------------------------------------------------------------------------
  # Verificação da Possibilidade de se Usar a Habilidade
  #
  #     skill_id : ID da Habilidade
  #--------------------------------------------------------------------------
 
  def skill_can_use?(skill_id)
    if not skill_learn?(skill_id)
      return false
    end
    return super
  end
 
  #--------------------------------------------------------------------------
  # Troca de Nome
  #
  #     name : novo nome
  #--------------------------------------------------------------------------
 
  def name=(name)
    @name = name
  end
 
  #--------------------------------------------------------------------------
  # Troca do ID de Classe
  #
  #     class_id : ID da classe
  #--------------------------------------------------------------------------
 
  def class_id=(class_id)
    if $data_classes[class_id] != nil
      @class_id = class_id
      # Equipamento que a Classe não permite é removido
      unless equippable?($data_weapons[@weapon_id])
        equip(0, 0)
      end
      unless equippable?($data_armors[@armor1_id])
        equip(1, 0)
      end
      unless equippable?($data_armors[@armor2_id])
        equip(2, 0)
      end
      unless equippable?($data_armors[@armor3_id])
        equip(3, 0)
      end
      unless equippable?($data_armors[@armor4_id])
        equip(4, 0)
      end
    end
  end
 
  #--------------------------------------------------------------------------
  # Troca de Gráficos
  #
  #     character_name : nome do arquivo do novo Herói
  #     character_hue  : cor do novo Herói
  #     battler_name   : nome do arquivo do novo Battler
  #     battler_hue    : cor do novo Battler
  #--------------------------------------------------------------------------
 
  def set_graphic(character_name, character_hue, battler_name, battler_hue)
    @character_name = character_name
    @character_hue = character_hue
    @battler_name = battler_name
    @battler_hue = battler_hue
  end
 
  #--------------------------------------------------------------------------
  # Tela de Batalha Coordenada X
  #--------------------------------------------------------------------------
 
  def screen_x
    # A partir de de uma fila no grupo, as coordenadas X são calculadas e 
    # desenvolvidas
    if self.index != nil
      return self.index * 160 + 80
    else
      return 0
    end
  end
 
  #--------------------------------------------------------------------------
  # Tela de Batalha Coordenada Y
  #--------------------------------------------------------------------------
 
  def screen_y
    return 464
  end
 
  #--------------------------------------------------------------------------
  # Tela de Batalha Coordenada Z
  #--------------------------------------------------------------------------
 
  def screen_z
    # A partir de de uma fila no grupo, as coordenadas Z são calculadas e 
    # desenvolvidas
    if self.index != nil
      return 4 - self.index
    else
      return 0
    end
  end
end
