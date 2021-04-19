#==============================================================================
# Game_Party
#------------------------------------------------------------------------------
# Esta classe engloba o Grupo de Heróis. Isto inclui informações sobre a
# quantidade de dinheiro e Itens. Se refere a $game_party para as instâncias
# nesta classe.
#==============================================================================

class Game_Party
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :actors                   # Heróis
  attr_reader   :gold                     # quantidade de dinheiro
  attr_reader   :steps                    # número de passos
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    # Criar a seta de Herói
    @actors = []
    # Inicializa a quantidade de dinheiro e número de passos
    @gold = 0
    @steps = 0
    # Cria individualmente a quantidade de itens, armas e armaduras
    @items = {}
    @weapons = {}
    @armors = {}
  end
  
  #--------------------------------------------------------------------------
  # Configuração do Grupo de Heróis Inicial
  #--------------------------------------------------------------------------
  
  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push($game_actors[i])
    end
  end
  
  #--------------------------------------------------------------------------
  # Configuração do Grupo de Heróis do teste de Batalha
  #--------------------------------------------------------------------------
  
  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.level = battler.level
      gain_weapon(battler.weapon_id, 1)
      gain_armor(battler.armor1_id, 1)
      gain_armor(battler.armor2_id, 1)
      gain_armor(battler.armor3_id, 1)
      gain_armor(battler.armor4_id, 1)
      actor.equip(0, battler.weapon_id)
      actor.equip(1, battler.armor1_id)
      actor.equip(2, battler.armor2_id)
      actor.equip(3, battler.armor3_id)
      actor.equip(4, battler.armor4_id)
      actor.recover_all
      @actors.push(actor)
    end
    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].name != ""
        occasion = $data_items[i].occasion
        if occasion == 0 or occasion == 1
          @items[i] = 99
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualizar os Membros do Grupo de Heróis
  #--------------------------------------------------------------------------
  
  def refresh
    # Objetos dos Heróis são dividos de $game_actors logo após carregar o jogo
    # Elimina-se este problema ao se resetar os Heróis a cada carregamento dos 
    # dados
    new_actors = []
    for i in 0...@actors.size
      if $data_actors[@actors[i].id] != nil
        new_actors.push($game_actors[@actors[i].id])
      end
    end
    @actors = new_actors
  end
  
  #--------------------------------------------------------------------------
  # Selecionando o Nível Máximo
  #--------------------------------------------------------------------------
  
  def max_level
    # Se for 0 os membros estão no grupo
    if @actors.size == 0
      return 0
    end
    # Inicializar variável local
    level = 0
    # Selecionar nível dos Heróis do Grupo
    for actor in @actors
      if level < actor.level
        level = actor.level
      end
    end
    return level
  end
  
  #--------------------------------------------------------------------------
  # Adicionar um Herói
  #
  #     actor_id : ID do Herói
  #--------------------------------------------------------------------------
  
  def add_actor(actor_id)
    # Selecionar Herói
    actor = $game_actors[actor_id]
    # Se o Grupo tiver menos do que 4 Heróis e o Herói já não estiver no Grupo
    if @actors.size < 4 and not @actors.include?(actor)
      # Adicionar Herói
      @actors.push(actor)
      # Atualizar Jogador
      $game_player.refresh
    end
  end
  
  #--------------------------------------------------------------------------
  # Remover Herói
  #
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  
  def remove_actor(actor_id)
    # Remover Herói
    @actors.delete($game_actors[actor_id])
    # Atualizar Jogador
    $game_player.refresh
  end
  
  #--------------------------------------------------------------------------
  # Ganhar Dinheiro
  #
  #     n : quantidade de dinheiro
  #--------------------------------------------------------------------------
  
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  
  #--------------------------------------------------------------------------
  # Perder Dinheiro
  #
  #     n : quantidade de dinheito
  #--------------------------------------------------------------------------
  
  def lose_gold(n)
    # Inverter o valor numerical e chamar isto de gain_gold
    gain_gold(-n)
  end
  
  #--------------------------------------------------------------------------
  # Acrescentar Passos
  #--------------------------------------------------------------------------
  
  def increase_steps
    @steps = [@steps + 1, 9999999].min
  end
  
  #--------------------------------------------------------------------------
  # Selecionar o Número de Itens Possuídos
  #
  #     item_id : ID do Item
  #--------------------------------------------------------------------------
  
  def item_number(item_id)
    # Se a quantidade estiver separada, se não, voltar a 0
    return @items.include?(item_id) ? @items[item_id] : 0
  end
  #--------------------------------------------------------------------------
  # Selecionar o Número de Armas Possuídas
  #
  #     weapon_id : ID da Arma
  #--------------------------------------------------------------------------
  
  def weapon_number(weapon_id)
    # Se a quantidade estiver separada, se não, voltar a 0
    return @weapons.include?(weapon_id) ? @weapons[weapon_id] : 0
  end
  
  #--------------------------------------------------------------------------
  # Selecionar o Número de Armaduras Possuídas
  #
  #     armor_id : ID da Armadura
  #--------------------------------------------------------------------------
  
  def armor_number(armor_id)
    # Se a quantidade estiver separada, se não, voltar a 0
    return @armors.include?(armor_id) ? @armors[armor_id] : 0
  end
  
  #--------------------------------------------------------------------------
  # Ganhou ou Perder Itens
  #
  #     item_id : iD do Item
  #     n       : quantidade
  #--------------------------------------------------------------------------
  
  def gain_item(item_id, n)
    # Atualizar a quantidade nesta divisão
    if item_id > 0
      @items[item_id] = [[item_number(item_id) + n, 0].max, 99].min
    end
  end
  
  #--------------------------------------------------------------------------
  # Ganhar ou Perder Armas
  #
  #     weapon_id : ID da Arma
  #     n         : quantidade
  #--------------------------------------------------------------------------
  
  def gain_weapon(weapon_id, n)
    # Atualizar a quantidade nesta divisão
    if weapon_id > 0
      @weapons[weapon_id] = [[weapon_number(weapon_id) + n, 0].max, 99].min
    end
  end
  
  #--------------------------------------------------------------------------
  # Ganhar ou Perder Armaduras
  #
  #     armor_id : ID da Armadura
  #     n        : quantidade
  #--------------------------------------------------------------------------
  
  def gain_armor(armor_id, n)
    # Atualizar a quantidade nesta divisão
    if armor_id > 0
      @armors[armor_id] = [[armor_number(armor_id) + n, 0].max, 99].min
    end
  end
  
  #--------------------------------------------------------------------------
  # Perder Itens
  #
  #     item_id : ID do Item
  #     n       : quantidade
  #--------------------------------------------------------------------------
  def lose_item(item_id, n)
    # Reverter o valor numerical e chamar gain_item
    gain_item(item_id, -n)
  end
  
  #--------------------------------------------------------------------------
  # Perder Armas
  #
  #     weapon_id : ID da Arma
  #     n         : quantidade
  #--------------------------------------------------------------------------
  
  def lose_weapon(weapon_id, n)
    # Reverter o valor numerical e chamar gain_weapon
    gain_weapon(weapon_id, -n)
  end
  
  #--------------------------------------------------------------------------
  # Perder Armadura
  #
  #     armor_id : ID da Armadura
  #     n        : quantidade
  #--------------------------------------------------------------------------
  
  def lose_armor(armor_id, n)
    # Reverter o valor numerical e chamar gain_armor
    gain_armor(armor_id, -n)
  end
  
  #--------------------------------------------------------------------------
  # Determinar se o Item é Usável
  #
  #     item_id : ID do Item
  #--------------------------------------------------------------------------
  
  def item_can_use?(item_id)
    # Se a quantidade do Item for 0
    if item_number(item_id) == 0
      # não usável
      return false
    end
    # Selecionar Itens usáveis
    occasion = $data_items[item_id].occasion
    # Se está em Batalha
    if $game_temp.in_battle
      # Se o local para usar for 0 (normal) ou 1 (batalhas) é usável
      return (occasion == 0 or occasion == 1)
    end
    # Se o local para usar for 0 (normal) ou 2 (menu) é usável
    return (occasion == 0 or occasion == 2)
  end
  
  #--------------------------------------------------------------------------
  # Limpar Todas as Ações dos Heróis
  #--------------------------------------------------------------------------
  
  def clear_actions
    # Limpar todas as ações dos Heróis
    for actor in @actors
      actor.current_action.clear
    end
  end
  
  #--------------------------------------------------------------------------
  # Determinar se o Comando é Possível
  #--------------------------------------------------------------------------
  
  def inputable?
    # Retornar verdadeiro se o comando for possível
    for actor in @actors
      if actor.inputable?
        return true
      end
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Determinar Quando Todo Mundo Estiver Morto
  #--------------------------------------------------------------------------
  
  def all_dead?
    # Se o número do Grupo de Heróis for 0
    if $game_party.actors.size == 0
      return false
    end
    # Se o Herói estiver no Grupo e tiver 0 de HP ou mais
    for actor in @actors
      if actor.hp > 0
        return false
      end
    end
    # Todos os membros estão mortos
    return true
  end
  
  #--------------------------------------------------------------------------
  # Receber Dano (para mapas)
  #--------------------------------------------------------------------------
  
  def check_map_slip_damage
    for actor in @actors
      if actor.hp > 0 and actor.slip_damage?
        actor.hp -= [actor.maxhp / 100, 1].max
        if actor.hp == 0
          $game_system.se_play($data_system.actor_collapse_se)
        end
        $game_screen.start_flash(Color.new(255,0,0,128), 4)
        $game_temp.gameover = $game_party.all_dead?
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Seleção Randômica de um Herói Alvo
  #
  #     hp0 : limita os Heróis que já estiverm mortos (hp=0)
  #--------------------------------------------------------------------------
  
  def random_target_actor(hp0 = false)
    # Iniciar roleta
    roulette = []
    # Loop
    for actor in @actors
      # Se isto se ajustar às condições
      if (not hp0 and actor.exist?) or (hp0 and actor.hp0?)
        # Selecionar classe do Herói [posição]
        position = $data_classes[actor.class_id].position
        # Defesa Frente: n = 4; Defesa Meio: n = 3; Defesa Atrás: n = 2
        n = 4 - position
        # Adicionar o Herói para a roleta n vezes
        n.times do
          roulette.push(actor)
        end
      end
    end
    # Se o tamanho da roleta for 0
    if roulette.size == 0
      return nil
    end
    # Girar o roleta e selecionar um Herói
    return roulette[rand(roulette.size)]
  end
  
  #--------------------------------------------------------------------------
  # Seleção Randômica de um Herói Alvo (HP0)
  #--------------------------------------------------------------------------
  
  def random_target_actor_hp0
    return random_target_actor(true)
  end
  
  #--------------------------------------------------------------------------
  # Seleção Suave de um Herói Alvo
  #
  #     actor_index : índice do Herói
  #--------------------------------------------------------------------------
  
  def smooth_target_actor(actor_index)
    # Selecionar um Herói
    actor = @actors[actor_index]
    # Aqui se verifica a existência do Herói
    if actor != nil and actor.exist?
      return actor
    end
    # Loop
    for actor in @actors
      # Se o Herói existir
      if actor.exist?
        return actor
      end
    end
  end
end
