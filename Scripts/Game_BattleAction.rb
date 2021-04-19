#==============================================================================
# Game_BattleAction
#------------------------------------------------------------------------------
# Esta classe considera as Ações de Batalha.
# Esta classe está inserida nas classes Game_Battler
#==============================================================================

class Game_BattleAction
 
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_accessor :speed                    # Velocidade
  attr_accessor :kind                     # Classificação (Básico/Magia/Item)
  attr_accessor :basic                    # Básico (Atacar/Defender/Esquivar)
  attr_accessor :skill_id                 # ID da Habilidade
  attr_accessor :item_id                  # ID do Item
  attr_accessor :target_index             # Índice de Itens
  attr_accessor :forcing                  # Flag de Ação Pré-Determinada
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    clear
  end
  
  #--------------------------------------------------------------------------
  # Esvaziar
  #--------------------------------------------------------------------------
  
  def clear
    @speed = 0
    @kind = 0
    @basic = 3
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
  end
  
  #--------------------------------------------------------------------------
  # Conceito de Efetivação
  #--------------------------------------------------------------------------
  
  def valid?
    return (not (@kind == 0 and @basic == 3))
  end
  
  #--------------------------------------------------------------------------
  # Conceito de Aliado
  #--------------------------------------------------------------------------
  
  def for_one_friend?
    # Para classificar, a Habilidade, o alcance é de um aliado, incluindo PV = 0
    if @kind == 1 and [3, 5].include?($data_skills[@skill_id].scope)
      return true
    end
    # Para classificar, o Item, o alcence é de um aliado, incluindo PV = 0
    if @kind == 2 and [3, 5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Conceito para Aliados
  #--------------------------------------------------------------------------
  
  def for_one_friend_hp0?
    # Para classificar, a Habilidade, o alcance é de um aliado, incluindo PV = 0
    if @kind == 1 and [5].include?($data_skills[@skill_id].scope)
      return true
    end
    # # Para classificar, o Item, o alcance é de um aliado, incluindo PV = 0
    if @kind == 2 and [5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Alvo Aleatório para Aliados
  #--------------------------------------------------------------------------
  
  def decide_random_target_for_actor
    # Alcances
    if for_one_friend_hp0?
      battler = $game_party.random_target_actor_hp0
    elsif for_one_friend?
      battler = $game_party.random_target_actor
    else
      battler = $game_troop.random_target_enemy
    end
    # Usar índice de Itens
    # Esvaziar evento, quando não existirem Itens
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end
  
  #--------------------------------------------------------------------------
  # Alvo Aleatório para Inimigos
  #--------------------------------------------------------------------------
  
  def decide_random_target_for_enemy
    # Alcance
    if for_one_friend_hp0?
      battler = $game_troop.random_target_enemy_hp0
    elsif for_one_friend?
      battler = $game_troop.random_target_enemy
    else
      battler = $game_party.random_target_actor
    end
    # Usar índice de Itens
    # Esvaziar evento, quando não existirem mais Itens
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end
  
  #--------------------------------------------------------------------------
  # Último Alvo para Heróis
  #--------------------------------------------------------------------------
  
  def decide_last_target_for_actor
    # Se o alcance do efeito é um Herói, o mesmo que executa a ação
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_party.actors[@target_index]
    else
      battler = $game_troop.enemies[@target_index]
    end
    # Esvaziar evento, quando não existirem mais Itens
    if battler == nil or not battler.exist?
      clear
    end
  end
  
  #--------------------------------------------------------------------------
  # Último Alvo para Inimigos
  #--------------------------------------------------------------------------
  
  def decide_last_target_for_enemy
    # Se o alcance do efeito é um Inimigo, o mesmo que executa a ação
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_troop.enemies[@target_index]
    else
      battler = $game_party.actors[@target_index]
    end
    # Esvaziar evento, quando não existirem mais Itens
    if battler == nil or not battler.exist?
      clear
    end
  end
end
