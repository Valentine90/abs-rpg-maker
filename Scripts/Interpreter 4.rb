#==============================================================================
# Interpreter (Parte 4)
#------------------------------------------------------------------------------
# É a classe que interpreta os comandos de eventos do jogo.
# É usada dentro da classe Game_Event e Game_System.
#==============================================================================

class Interpreter
  
  #--------------------------------------------------------------------------
  # Opções de Switch
  #--------------------------------------------------------------------------
  
  def command_121
    # Loop para controle do grupo
    for i in @parameters[0] .. @parameters[1]
      # Alterar Switch
      $game_switches[i] = (@parameters[2] == 0)
    end
    # Atualizar mapa
    $game_map.need_refresh = true
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opções de Variável
  #--------------------------------------------------------------------------
  
  def command_122
    # Inicializar valor
    value = 0
    # Ramificação com operações
    case @parameters[3]
    when 0  # Invariável
      value = @parameters[4]
    when 1  # Variável
      value = $game_variables[@parameters[4]]
    when 2  # Número aleatório
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
    when 3  # Item
      value = $game_party.item_number(@parameters[4])
    when 4  # Herói
      actor = $game_actors[@parameters[4]]
      if actor != nil
        case @parameters[5]
        when 0  # Nível
          value = actor.level
        when 1  # EXP
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # MP
          value = actor.sp
        when 4  # HP Máximo
          value = actor.maxhp
        when 5  # MP Máximo
          value = actor.maxsp
        when 6  # Força
          value = actor.str
        when 7  # Destreza
          value = actor.dex
        when 8  # Agilidade
          value = actor.agi
        when 9  # Magia
          value = actor.int
        when 10  # Poder de Ataque
          value = actor.atk
        when 11  # Defesa
          value = actor.pdef
        when 12  # Defesa Mágica
          value = actor.mdef
        when 13  # Esquiva
          value = actor.eva
        end
      end
    when 5  # Inimigo
      enemy = $game_troop.enemies[@parameters[4]]
      if enemy != nil
        case @parameters[5]
        when 0  # HP
          value = enemy.hp
        when 1  # MP
          value = enemy.sp
        when 2  # HP Máximo
          value = enemy.maxhp
        when 3  # MP Máximo
          value = enemy.maxsp
        when 4  # Força
          value = enemy.str
        when 5  # Destreza
          value = enemy.dex
        when 6  # Agilidade
          value = enemy.agi
        when 7  # Magia
          value = enemy.int
        when 8  # Poder de Ataque
          value = enemy.atk
        when 9  # Defesa
          value = enemy.pdef
        when 10 # Defesa Mágica
          value = enemy.mdef
        when 11 # Esquiva
          value = enemy.eva
        end
      end
    when 6  # Herói
      character = get_character(@parameters[4])
      if character != nil
        case @parameters[5]
        when 0  # Coordenada x
          value = character.x
        when 1  # Coordenada y
          value = character.y
        when 2  # Direção
          value = character.direction
        when 3  # Coordenada x da tela
          value = character.screen_x
        when 4  # Coordenada y da tela
          value = character.screen_y
        when 5  # Tag do terreno
          value = character.terrain_tag
        end
      end
    when 7  # Outro
      case @parameters[4]
      when 0  # ID do mapa
        value = $game_map.map_id
      when 1  # Número de membros do Grupo de Heróis
        value = $game_party.actors.size
      when 2  # Dinheiro
        value = $game_party.gold
      when 3  # Passos
        value = $game_party.steps
      when 4  # Tempo de Jogo
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # Temporizador
        value = $game_system.timer / Graphics.frame_rate
      when 6  # Contador de saves
        value = $game_system.save_count
      end
    end
    # Loop para controle de grupo
    for i in @parameters[0] .. @parameters[1]
      # Ramificação com controle
      case @parameters[2]
      when 0  # Substituir
        $game_variables[i] = value
      when 1  # Adicionar
        $game_variables[i] += value
      when 2  # Subtrair
        $game_variables[i] -= value
      when 3  # Multiplicar
        $game_variables[i] *= value
      when 4  # Dividir
        if value != 0
          $game_variables[i] /= value
        end
      when 5  # Porcentagem
        if value != 0
          $game_variables[i] %= value
        end
      end
      # Checagem de limite máximo
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      # Checagem de limite mínimo
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    # Atualizar mapa
    $game_map.need_refresh = true
    # Continue
    return true
  end
  
  #--------------------------------------------------------------------------
  # Controle de Switch Local
  #--------------------------------------------------------------------------
  
  def command_123
    # Se o ID do evento for válido
    if @event_id > 0
      # Criar uma chave de Auto-Switch
      key = [$game_map.map_id, @event_id, @parameters[0]]
      # Mudar Auto-Switches
      $game_self_switches[key] = (@parameters[1] == 0)
    end
    # Atualizar mapa
    $game_map.need_refresh = true
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Operações de Tempo
  #--------------------------------------------------------------------------
  
  def command_124
    # Se iníciou
    if @parameters[0] == 0
      $game_system.timer = @parameters[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    # Se parou
    if @parameters[0] == 1
      $game_system.timer_working = false
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Dinheiro
  #--------------------------------------------------------------------------
  
  def command_125
    # Selecionar valor para operar
    value = operate_value(@parameters[0], @parameters[1], @parameters[2])
    # Alterar a quantidade de Dinheiro
    $game_party.gain_gold(value)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Itens
  #--------------------------------------------------------------------------
  
  def command_126
    # Selecionar valor para operar
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Acrescentar / remover certa quantidade de Itens
    $game_party.gain_item(@parameters[0], value)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Armas
  #--------------------------------------------------------------------------
  
  def command_127
    # Selecionar valor para operar
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Acrescentar / Remover Armas
    $game_party.gain_weapon(@parameters[0], value)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Armaduras
  #--------------------------------------------------------------------------
  
  def command_128
    # Selecionar valor para operar
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Acrescentar / Remover Armaduras
    $game_party.gain_armor(@parameters[0], value)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Grupo
  #--------------------------------------------------------------------------
  
  def command_129
    # Selecionar Herói
    actor = $game_actors[@parameters[0]]
    # Se o Herói for válido
    if actor != nil
      # Ramificação com controle
      if @parameters[1] == 0
        if @parameters[2] == 1
          $game_actors[@parameters[0]].setup(@parameters[0])
        end
        $game_party.add_actor(@parameters[0])
      else
        $game_party.remove_actor(@parameters[0])
      end
    end
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar Gráfico de Sistema
  #--------------------------------------------------------------------------
  
  def command_131
    # Mudar nome do arquivo da gráfico de sistema
    $game_system.windowskin_name = @parameters[0]
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar BGM de Batalha
  #--------------------------------------------------------------------------
  
  def command_132
    # Mudar BGM de batalha
    $game_system.battle_bgm = @parameters[0]
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Mudar ME de Batalha
  #--------------------------------------------------------------------------
  
  def command_133
    # Mudar ME de batalha
    $game_system.battle_end_me = @parameters[0]
    # Continue
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opções de Save
  #--------------------------------------------------------------------------
  
  def command_134
    # Mudar flag de acesso ao comando salvar
    $game_system.save_disabled = (@parameters[0] == 0)
    # Continue
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opções de Menu
  #--------------------------------------------------------------------------
  
  def command_135
    # Mudar flag de acesso ao Menu
    $game_system.menu_disabled = (@parameters[0] == 0)
    # Continuar
    return true
  end
  
  #--------------------------------------------------------------------------
  # Opções de Encontro
  #--------------------------------------------------------------------------
  
  def command_136
    # Mudar flag de contador de encontro
    $game_system.encounter_disabled = (@parameters[0] == 0)
    # Criar contador de encontro
    $game_player.make_encounter_count
    # Continuar
    return true
  end
end
