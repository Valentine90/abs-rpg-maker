#==============================================================================
# Game_Enemy
#------------------------------------------------------------------------------
# Este é a classe que trata dos inimigos. Esta classe é usada juntamente com
# a classe Game_Troop ($game_troop)
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # Inicialização de Objetos
  #
  #     troop_id     : ID do Grupo de Inimigos
  #     member_index : Índice de Inimigos
  #--------------------------------------------------------------------------
  
  def initialize(troop_id, member_index)
    super()
    @troop_id = troop_id
    @member_index = member_index
    troop = $data_troops[@troop_id]
    @enemy_id = troop.members[@member_index].enemy_id
    enemy = $data_enemies[@enemy_id]
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @sp = maxsp
    @hidden = troop.members[@member_index].hidden
    @immortal = troop.members[@member_index].immortal
  end
  
  #--------------------------------------------------------------------------
  # Selecionar o ID do Inimigo
  #--------------------------------------------------------------------------
  
  def id
    return @enemy_id
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Índice
  #--------------------------------------------------------------------------
  
  def index
    return @member_index
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Nome
  #--------------------------------------------------------------------------
  
  def name
    return $data_enemies[@enemy_id].name
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Base do MaxHP
  #--------------------------------------------------------------------------
  
  def base_maxhp
    return $data_enemies[@enemy_id].maxhp
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Base do MaxMP
  #--------------------------------------------------------------------------
  
  def base_maxsp
    return $data_enemies[@enemy_id].maxsp
  end
  
  #--------------------------------------------------------------------------
  # - Selecionar Base de Ataque
  #--------------------------------------------------------------------------
  
  def base_str
    return $data_enemies[@enemy_id].str
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Base da Defesa
  #--------------------------------------------------------------------------
  
  def base_dex
    return $data_enemies[@enemy_id].dex
  end
  #--------------------------------------------------------------------------
  # Selecionar Base da Agilidade
  #--------------------------------------------------------------------------
  
  def base_agi
    return $data_enemies[@enemy_id].agi
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Base da Inteligência
  #--------------------------------------------------------------------------
  
  def base_int
    return $data_enemies[@enemy_id].int
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Base da Força
  #--------------------------------------------------------------------------
  
  def base_atk
    return $data_enemies[@enemy_id].atk
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Base da Defesa Física
  #--------------------------------------------------------------------------
  
  def base_pdef
    return $data_enemies[@enemy_id].pdef
  end
  
  #--------------------------------------------------------------------------
  # - Selecionar Base da Defesa Mágica
  #--------------------------------------------------------------------------
  
  def base_mdef
    return $data_enemies[@enemy_id].mdef
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Base da Esquiva
  #--------------------------------------------------------------------------
  
  def base_eva
    return $data_enemies[@enemy_id].eva
  end
  
  #--------------------------------------------------------------------------
  # Selecionar o ID de Animação de Ataque Normal
  #--------------------------------------------------------------------------
  
  def animation1_id
    return $data_enemies[@enemy_id].animation1_id
  end
  
  #--------------------------------------------------------------------------
  # Selecionar o ID do Alvo da Animação de Ataque Normal
  #--------------------------------------------------------------------------
  def animation2_id
    return $data_enemies[@enemy_id].animation2_id
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Revisão do Valor de Atributo
  #
  #     element_id : ID do Elemento
  #--------------------------------------------------------------------------
  
  def element_rate(element_id)
    # Aqui é selecionado um valor numérico relativo ao efeito do atributo
    table = [0,200,150,100,50,0,-100]
    result = table[$data_enemies[@enemy_id].element_ranks[element_id]]
    # Se for protegido por um Status, cortar o dano pela metade
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # Fim do Método
    return result
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Efetividade do Status
  #--------------------------------------------------------------------------
  
  def state_ranks
    return $data_enemies[@enemy_id].state_ranks
  end
  
  #--------------------------------------------------------------------------
  # Determinar a Defesa à Status
  #     state_id : ID do Status
  #--------------------------------------------------------------------------
  
  def state_guard?(state_id)
    return false
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Ataque de Atributo Normal
  #--------------------------------------------------------------------------
  
  def element_set
    return []
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Troca de Status do Ataque Normal (+)
  #--------------------------------------------------------------------------
  
  def plus_state_set
    return []
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Troca de Status do Ataque Normal (-)
  #--------------------------------------------------------------------------
  
  def minus_state_set
    return []
  end
  
  #--------------------------------------------------------------------------
  # Adquirir Ações
  #--------------------------------------------------------------------------
  
  def actions
    return $data_enemies[@enemy_id].actions
  end
  
  #--------------------------------------------------------------------------
  # Selecionar EXP
  #--------------------------------------------------------------------------
  
  def exp
    return $data_enemies[@enemy_id].exp
  end
  
  #--------------------------------------------------------------------------
  # - Selecionar Dinheiro
  #--------------------------------------------------------------------------
  
  def gold
    return $data_enemies[@enemy_id].gold
  end
  
  #--------------------------------------------------------------------------
  # Selecionar ID do Item
  #--------------------------------------------------------------------------
  
  def item_id
    return $data_enemies[@enemy_id].item_id
  end
  
  #--------------------------------------------------------------------------
  # Selecionar ID da Arma
  #--------------------------------------------------------------------------
  
  def weapon_id
    return $data_enemies[@enemy_id].weapon_id
  end
  
  #--------------------------------------------------------------------------
  # Selecionar ID da Armadura
  #--------------------------------------------------------------------------
  
  def armor_id
    return $data_enemies[@enemy_id].armor_id
  end
  
  #--------------------------------------------------------------------------
  # Definir a Probabilidade de Aparecer o Tesouro
  #--------------------------------------------------------------------------
  def treasure_prob
    return $data_enemies[@enemy_id].treasure_prob
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Coordenada X da Tela de Batalha
  #--------------------------------------------------------------------------
  
  def screen_x
    return $data_troops[@troop_id].members[@member_index].x
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Coordenada Y da Tela de Batalha
  #--------------------------------------------------------------------------
  
  def screen_y
    return $data_troops[@troop_id].members[@member_index].y
  end
  
  #--------------------------------------------------------------------------
  # Selecionar a Coordenada Z da Tela de Batalha
  #--------------------------------------------------------------------------
  
  def screen_z
    return screen_y
  end
  
  #--------------------------------------------------------------------------
  # Fugir
  #--------------------------------------------------------------------------
  
  def escape
    # Selecionar flag de escondido
    @hidden = true
    # Limpar ação atual
    self.current_action.clear
  end
  
  #--------------------------------------------------------------------------
  # Transformar
  #
  #     enemy_id : ID do Inimigo a ser transformado
  #--------------------------------------------------------------------------
 
  def transform(enemy_id)
    # Mudar o ID do Inimigo
    @enemy_id = enemy_id
    # Mudar os Gráficos
    @battler_name = $data_enemies[@enemy_id].battler_name
    @battler_hue = $data_enemies[@enemy_id].battler_hue
    # Recriar ação
    make_action
  end
  
  #--------------------------------------------------------------------------
  # Recriar Ação
  #--------------------------------------------------------------------------
  
  def make_action
    # Limpar ação atual
    self.current_action.clear
    # Se puder se mover
    unless self.movable?
      # Fim do método
      return
    end
    # Extrair as ações efetivas atuais
    available_actions = []
    rating_max = 0
    for action in self.actions
      # Confirmar as condições de Turno
      n = $game_temp.battle_turn
      a = action.condition_turn_a
      b = action.condition_turn_b
      if (b == 0 and n != a) or
         (b > 0 and (n < 1 or n < a or n % b != a % b))
        next
      end
      # Confirmar as condições de HP
      if self.hp * 100.0 / self.maxhp > action.condition_hp
        next
      end
      # Confirmar as condições de Nível
      if $game_party.max_level < action.condition_level
        next
      end
      # Confirmar as condições de Switch
      switch_id = action.condition_switch_id
      if switch_id > 0 and $game_switches[switch_id] == false
        next
      end
      # Adicionar esta ação às condições aplicáveis
      available_actions.push(action)
      if action.rating > rating_max
        rating_max = action.rating
      end
    end
    # Calcular o total com um grau máximo de valor 3 (excluindo 0 ou menos)
    ratings_total = 0
    for action in available_actions
      if action.rating > rating_max - 3
        ratings_total += action.rating - (rating_max - 3)
      end
    end
    # Se o grau for maior do que 0
    if ratings_total > 0
      # Criar números aleatórios
      value = rand(ratings_total)
      # Selecionar coisas que se correspondem para criar números aleatórios como ações atuais
      for action in available_actions
        if action.rating > rating_max - 3
          if value < action.rating - (rating_max - 3)
            self.current_action.kind = action.kind
            self.current_action.basic = action.basic
            self.current_action.skill_id = action.skill_id
            self.current_action.decide_random_target_for_enemy
            return
          else
            value -= action.rating - (rating_max - 3)
          end
        end
      end
    end
  end
end
