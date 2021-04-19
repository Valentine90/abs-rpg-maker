#==============================================================================
# ** Diamond Action Battle System
#------------------------------------------------------------------------------
# Autor: Valentine
#==============================================================================

# Tecla utilizada para o herói atacar
ATTACK_KEY = Input::Key['S']

# Tecla utilizada para o herói se defender
DEFEND_KEY = Input::Key['D']

# Teclas de atalho usadas para lançar itens e habilidades
HOTKEYS = [
  Input::Key['NumberKey 1'],
  Input::Key['NumberKey 2'],
  Input::Key['NumberKey 3'],
  Input::Key['NumberKey 4'],
  Input::Key['NumberKey 5'],
  Input::Key['NumberKey 6'],
  Input::Key['NumberKey 7'],
  Input::Key['NumberKey 8'],
  Input::Key['NumberKey 9']
]

# Intervalo (em frames) entre os ataques do herói
ATTACK_TIME = 30

# Intervalo (em segundos) entre a morte e o renascimento dos inimigos
RESPAWN_TIME = 5

# Tempo (em segundos) para o item desaparecer do chão
DROP_DESPAWN_TIME = 60

# Tempo (em segundos) para recuperar o HP e o SP do herói
RECOVER_TIME = 5

# Fórmula: (AGI / 100) * RECOVER_HP
# Quantidade de HP a ser recuperado
RECOVER_HP = 20

# Fórmula: (AGI / 100) * RECOVER_SP
# Quantidade de SP a ser recuperado
RECOVER_SP = 20

# ID da animação utilizada ao subir de nível
LEVEL_UP_ANIMATION_ID = 33

# Máximo de itens caídos no chão por mapa
MAX_MAP_DROPS = 15

# Ícone do ouro
GOLD_ICON = '032-Item01'

# Armas de longo alcance
RANGE_WEAPONS = {}
# RANGE_WEAPONS[ID da arma] = [gráfico, ID do item, ID da animação, velocidade, alcance, animação (opcional), sufixo (opcional)]
RANGE_WEAPONS[17] = ['Arrow', 30, 4, 4, 15, false, '_bow']
RANGE_WEAPONS[18] = ['Arrow', 30, 4, 4, 15, false, '_bow']
RANGE_WEAPONS[19] = ['Arrow', 30, 4, 4, 15, false, '_bow']
RANGE_WEAPONS[20] = ['Arrow', 30, 4, 4, 15, false, '_bow']
RANGE_WEAPONS[21] = ['Bullet', 31, 4, 4, 15, false, '_gun']
RANGE_WEAPONS[22] = ['Bullet', 31, 4, 4, 15, false, '_gun']
RANGE_WEAPONS[23] = ['Bullet', 31, 4, 4, 15, false, '_gun']
RANGE_WEAPONS[14] = ['Bullet', 31, 4, 4, 15, false, '_gun']
RANGE_WEAPONS[33] = ['Bullet', 31, 5, 4, 15, false, '_gun']

# Habilidades de longo alcance
RANGE_SKILLS = {}
# RANGE_SKILLS[ID da habilidade] = [gráfico, velocidade, alcance, animação (opcional), sufixo (opcional)]
RANGE_SKILLS[57] = ['Fire02', 4, 15, true, '_cast']

# Explosivos de longo alcance
RANGE_EXPLODE = {}
# RANGE_EXPLODE[ID da habilidade] = [gráfico, velocidade, alcance, alcance da explosão, animação (opcional), sufixo (opcional)]
RANGE_EXPLODE[7] = ['ArrowExplode', 4, 15, 3, false, '_cast']

# Animação da arma
MELEE_ANIMATION = {}
# MELEE_ANIMATION[ID da arma] = sufixo da animação
MELEE_ANIMATION[1] = '_melee'
MELEE_ANIMATION[2] = '_melee'
MELEE_ANIMATION[3] = '_melee'
MELEE_ANIMATION[4] = '_melee'

# Animação da habilidade
SKILL_ANIMATION = {}
# SKILL_ANIMATION[ID da habilidade] = sufixo da animação
SKILL_ANIMATION[1] = '_cast'

# Animação do escudo
DEFEND_ANIMATION = {}
# DEFEND_ANIMATION[ID do escudo] = sufixo da animação
DEFEND_ANIMATION[1] = '_defend'
DEFEND_ANIMATION[2] = '_defend'
DEFEND_ANIMATION[3] = '_defend'
DEFEND_ANIMATION[4] = '_defend'

# Tempo para a arma ser utilizada novamente
COOLDOWN_WEAPONS = {}
# COOLDOWN_WEAPONS[ID da arma] = tempo (em frames)
COOLDOWN_WEAPONS[33] = 15

# Tempo (em frames) para a habilidade ser utilizada novamente após ser lançada
COOLDOWN_SKILL = 30

# Habilidade em área
AREA_SKILLS = {}
# AREA_SKILLS[ID da habilidade] = área (em tiles)
AREA_SKILLS[58] = 5

# Tempo de duração dos status
STATES = []
# STATES[ID do status] = tempo (em segundos)
STATES[1] = 0 # Até ser curado
STATES[2] = 10
STATES[3] = 10
STATES[4] = 10
STATES[5] = 10
STATES[6] = 10
STATES[7] = 10
STATES[8] = 10
STATES[9] = 10
STATES[10] = 10
STATES[11] = 10
STATES[12] = 10

# Textos
DAMAGE_TEXTS = ['Errou!', 'Crítico!', 'Subiu nível!']

# Texto mostrado ao memorizar um item ou uma habilidade
MEMORIZED_TEXT = 'Memorizou!'

# Nome, negrito e tamanho da fonte do dano
DAMAGE_FONT_NAME = 'Arial Black'
DAMAGE_FONT_BOLD = true
DAMAGE_FONT_SIZE = 18

# Cor dos textos
DAMAGE_COLORS = [
  Color.new(255, 255, 255), # Crítico
  Color.new(255, 255, 255), # Dano
  Color.new(176, 255, 144), # Cura
  Color.new(255, 255, 255), # Errou
  Color.new(255, 255, 0),   # Experiência
  Color.new(255, 255, 255)  # Subiu nível
]

#==============================================================================
# ** Kernel
#==============================================================================
module RPG::Cache
  #--------------------------------------------------------------------------
  # * Projécteis
  #     filename : nome do arquivo
  #     hue      : tonalidade
  #--------------------------------------------------------------------------
  def self.projectiles(filename, hue = 0)
    self.load_bitmap('Graphics/Projectiles/', filename, hue)
  end
end

#==============================================================================
# ** Game_Temp
#==============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  alias diamond_abs_initialize initialize
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_accessor :need_update              # atualizar flag requerida
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #--------------------------------------------------------------------------
  def initialize
    diamond_abs_initialize
    @need_update = false
  end
end

#==============================================================================
# ** Game_Battler
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  alias diamond_abs_add_state add_state
  #--------------------------------------------------------------------------
  # * Aplicar troca de status (+)
  #     plus_state_set  : trocar status (+)
  #--------------------------------------------------------------------------
  def states_plus(plus_state_set)
    effective = false
    for i in plus_state_set
      # Quando o status não é definido
      unless self.state_guard?(i)
        effective |= self.state_full?(i) == false
        # Status sem resistência
        if $data_states[i].nonresistance
          @state_changed = true
          add_state(i, false, true)
        # Quando o status não estiver cheio
        elsif self.state_full?(i) == false
          if rand(100) < [0, 100, 80, 60, 40, 20, 0][self.state_ranks[i]]
            @state_changed = true
            add_state(i, false, true)
          end
        end
      end
    end
    return effective
  end
  #--------------------------------------------------------------------------
  # * Verificação da habilidade
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    return false if $data_skills[skill_id].sp_cost > self.sp
    return false if dead?
    # Se estiver com o status mudo também não é possível utilizar a habilidade
    return false if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
    # Definição do tempo de uso
    occasion = $data_skills[skill_id].occasion
    # Sempre ou somente em batalha
    return (occasion == 0 or occasion == 1)
  end
  #--------------------------------------------------------------------------
  # * Aplicação do efeito de um ataque
  #     attacker : atacante
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    self.critical = false
    hit_result = (rand(100) < attacker.hit)
    # Em caso de ataque á distância
    if hit_result == true
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      if self.damage > 0
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        # Calcular defesa
        self.damage /= 2 if self.guarding?
      end
      # Aplicar dano
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
        # Corrigir dano
        self.damage = self.hp if self.damage > self.hp
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
      self.hp -= self.damage
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # Se houver falha
    else
      self.damage = DAMAGE_TEXTS[0]
      self.critical = false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Aplicação do efeito da habilidade
  #     user  : usuário
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_effect(user, skill)
    self.critical = false
    # O alcance da habilidade é um aliado com 1 de HP ou efeito da habilidade em um aliado de HP 0
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      return false
    end
    effective = false
    effective |= skill.common_event_id > 0
    hit = skill.hit
    hit *= user.hit / 100 if skill.atk_f > 0
    hit_result = (rand(100) < hit)
    # Se a habilidade não for efetiva
    effective |= hit < 100
    # Se acertar
    if hit_result == true
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      self.damage = power * rate / 20
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      # Quando o dano for positivo
      if self.damage > 0
        # Calcular defesa
        self.damage /= 2 if self.guarding?
      end
      # Aplicação do dano
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
        # Corrigir dano
        self.damage = self.hp if self.damage > self.hp
        # Corrigir cura
        self.damage = -(self.maxhp - self.hp) if self.damage < 0 and self.damage.abs > self.maxhp - self.hp
      end
      # Verificar segundo ataque
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # Se a habilidade não for efetiva
      effective |= hit < 100
    end
    # Se acertar
    if hit_result == true
      if skill.power != 0 and skill.atk_f > 0
        # Aplicação do status de choque
        remove_states_shock
        effective = true
      end
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      # Corrigir cura quando o HP for igual ao MaxHP
      self.damage = nil if self.damage == 0
      # Se a força for 0
      if skill.power == 0
        self.damage = ''
        # Quando o status não é alterado
        self.damage = DAMAGE_TEXTS[0] unless @state_changed
      end
    # Se errar
    else
      self.damage = DAMAGE_TEXTS[0]
    end
    return effective
  end
  #--------------------------------------------------------------------------
  # * Aplicação do efeito de um item
  #     item : item
  #--------------------------------------------------------------------------
  def item_effect(item)
    self.critical = false
    # O alcance da habilidade é um aliado com 1 de HP ou efeito da habilidade em um aliado de HP 0
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      return false
    end
    effective = false
    effective |= item.common_event_id > 0
    # Verificar se for um ataque à distância
    hit_result = (rand(100) < item.hit)
    # Se a habilidade não for efetiva
    effective |= item.hit < 100
    # Se acertar
    if hit_result == true
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
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
        recover_hp /= 2 if self.guarding?
      end
      # Corrigir recuperação
      recover_hp = self.maxhp - self.hp if recover_hp > self.maxhp - self.hp
      # A recuperação de MP se inverte e é fixa como o valor do dano
      self.damage = -recover_hp if recover_hp > 0
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
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
        # Aplicar flag de efeito
        effective = true
      end
      # Proporção de recuperação de HP
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        self.damage = ''
        # Proporção de recuperação de MP
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # Quando trocar de status
          self.damage = DAMAGE_TEXTS[0] unless @state_changed
        end
      end
    # Se errar
    else
      self.damage = DAMAGE_TEXTS[0]
    end
    return effective
  end
  #--------------------------------------------------------------------------
  # * Uso do status
  #     state_id : ID do status
  #     force    : flag compulsiva
  #     target   : alvo
  #--------------------------------------------------------------------------
  def add_state(state_id, force = false, target = false)
    diamond_abs_add_state(state_id, force)
    @target = $game_map.events[@event_id].target if target and $data_states[state_id].slip_damage and @event_id
  end
  #--------------------------------------------------------------------------
  # * Aplicação do comando receber dano
  #--------------------------------------------------------------------------
  def slip_damage_effect
    self.damage = self.maxhp / 10
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp + 1) + rand(amp + 1) - amp
    end
    self.hp -= self.damage
    # Mudar alvo se o inimigo morreu
    $game_map.events[@event_id].target = @target if dead? and @target
    return true
  end
end

#==============================================================================
# ** Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  alias diamond_abs_setup setup
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_accessor :hotkeys                  # atalhos
  #--------------------------------------------------------------------------
  # * Opções
  #     actor_id : ID do herói
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @hotkeys = {}
    diamond_abs_setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # * Experiência atual
  #--------------------------------------------------------------------------
  def now_exp
    return @level < $data_actors[1].final_level ? @exp - @exp_list[@level] : '-------'
  end
  #--------------------------------------------------------------------------
  # * Experiência necessária para o próximo nível
  #--------------------------------------------------------------------------
  def next_exp
    return @level < $data_actors[1].final_level ? @exp_list[@level + 1] - @exp_list[@level] : '-------'
  end
  #--------------------------------------------------------------------------
  # * Troca de experiência
  #     exp : nova experiência
  #--------------------------------------------------------------------------
  def exp=(exp)
    last_level = @level
    @exp = [[exp, 9999999].min, 0].max
    while @exp >= @exp_list[@level + 1] and @exp_list[@level + 1] > 0
      @level += 1
      for j in $data_classes[@class_id].learnings
        learn_skill(j.skill_id) if j.level == @level
      end
    end
    # Agravante
    @level -= 1 while @exp < @exp_list[@level]
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
    if @level > last_level and $scene.is_a?(Scene_Map)
      $game_player.animation_id = LEVEL_UP_ANIMATION_ID
      self.damage = DAMAGE_TEXTS[2]
      recover_all
    end
  end
end

#==============================================================================
# ** Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Inicialização de objetos
  #     enemy_id : ID do inimigo
  #     event_id : ID do evento
  #--------------------------------------------------------------------------
  def initialize(enemy_id, event_id)
    super()
    @enemy_id = enemy_id
    @event_id = event_id
    # Calcular novamente o HP e SP
    @hp = maxhp
    @sp = maxsp
  end
end

#==============================================================================
# ** Game_Party
#==============================================================================
class Game_Party
  #--------------------------------------------------------------------------
  # * Ganhar ou perder itens
  #     item_id : ID do item
  #     n       : quantidade
  #--------------------------------------------------------------------------
  def gain_item(item_id, n)
    @items[item_id] = [[item_number(item_id) + n, 0].max, 99].min if item_id > 0
    $scene.hotbar_sprite.refresh if $scene.is_a?(Scene_Map)
  end
end

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * No tela?
  #     object : objeto
  #--------------------------------------------------------------------------
  def in_screen?(object)
    return false if object.real_x <= @display_x - 512
    return false if object.real_x >= @display_x + 2944 # 23 tiles
    return false if object.real_y <= @display_y - 512
    return false if object.real_y >= @display_y + 2304 # 18 tiles
    return true
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    refresh if $game_map.need_refresh
    # Se estiver ocorrendo o scroll
    if @scroll_rest > 0
      # Mudar da velocidade de scroll para as coordenadas de distância do mapa
      distance = 2 ** @scroll_speed
      case @scroll_direction
      when 2  # Baixo
        scroll_down(distance)
      when 4  # Esquerda
        scroll_left(distance)
      when 6  # Direita
        scroll_right(distance)
      when 8  # Cima
        scroll_up(distance)
      end
      @scroll_rest -= distance
    end
    update_events
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do eventos
  #--------------------------------------------------------------------------
  def update_events
    for event in @events.values
      # Se o evento estiver na área, início automático ou processo paralelo
      event.update if in_screen?(event) or event.trigger == 3 or event.trigger == 4
    end
    for common_event in @common_events.values
      common_event.update
    end
  end
end

#==============================================================================
# ** Game_Character
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  alias diamond_abs_gchar_initialize initialize
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :actor                    # herói
  attr_accessor :reward                   # recompensa
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #--------------------------------------------------------------------------
  def initialize
    diamond_abs_gchar_initialize
    @attack_delay = 20
    @state_time = 0
  end
  #--------------------------------------------------------------------------
  # * No alcance?
  #     target : alvo
  #     range  : alcance
  #--------------------------------------------------------------------------
  def in_range?(target, range)
    return (@x - target.x).abs <= range && (@y - target.y).abs <= range
  end
  #--------------------------------------------------------------------------
  # * Em frente?
  #     target : alvo
  #--------------------------------------------------------------------------
  def in_front?(target)
    return true if @direction == 2 and target.y - 1 == @y and target.x == @x
    return true if @direction == 4 and target.x + 1 == @x and target.y == @y
    return true if @direction == 6 and target.x - 1 == @x and target.y == @y
    return true if @direction == 8 and target.y + 1 == @y and target.x == @x
    return false
  end
  #--------------------------------------------------------------------------
  # * Na direção?
  #     target : alvo
  #--------------------------------------------------------------------------
  def in_direction?(target)
    return true if @direction == 2 and target.y >= @y and target.x == @x
    return true if @direction == 4 and target.x <= @x and target.y == @y
    return true if @direction == 6 and target.x >= @x and target.y == @y
    return true if @direction == 8 and target.y <= @y and target.x == @x
    return false
  end
  #--------------------------------------------------------------------------
  # * Herói ou inimigo?
  #--------------------------------------------------------------------------
  def actor?
    @actor
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade de longo alcance
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_attack_range(skill)
    projectile_name, speed, range, animation_id, sufix = RANGE_SKILLS[skill.id]
    animate_attack(sufix) if sufix
    $game_range << Game_Range.new(self, projectile_name, skill.animation2_id, speed, range, animation_id, skill.id)
  end
  #--------------------------------------------------------------------------
  # * Ataque com explosivo de longo alcance
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_explode_range(skill)
    projectile_name, speed, range, explosion_range, animation_id, sufix = RANGE_EXPLODE[skill.id]
    animate_attack(sufix) if sufix
    $game_range << Game_Range.new(self, projectile_name, skill.animation2_id, speed, range, animation_id, skill.id, explosion_range)
  end
  #--------------------------------------------------------------------------
  # * Recuperar
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_recover(skill)
    animate_attack(SKILL_ANIMATION[skill.id]) if SKILL_ANIMATION.has_key?(skill.id)
    @actor.skill_effect(@actor, skill)
    @animation_id = skill.animation2_id if skill.animation2_id > 0
  end
  #--------------------------------------------------------------------------
  # * Animação do ataque
  #     suffix : sufixo
  #--------------------------------------------------------------------------
  def animate_attack(suffix)
    return unless FileTest.exist?("Graphics/Characters/#{@character_name}#{suffix}.png")
    @old_character_name = @character_name
    @old_pattern = @pattern
    @old_anime = @step_anime
    @character_name = "#{@character_name}#{suffix}"
    @pattern = 0
    @step_anime = true
    @attack_delay = 0
  end
  #--------------------------------------------------------------------------
  # * Seguir alvo
  #     target : alvo
  #--------------------------------------------------------------------------
  def move_toward_target(target)
    sx = @x - target.x
    sy = @y - target.y
    # Se as coordenadas forem iguais
    return if sx == 0 and sy == 0
    abs_sx = sx.abs
    abs_sy = sy.abs
    # Se as distâncias vertical e horizontal forem as mesmas
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # Se a distância horizontal for a mais longínqua
    if abs_sx > abs_sy
      # Seguir alvo, priorizando os movimento direita e esquerda
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # Se a distância vertical for a mais longínqua
    else
      # Seguir alvo, priorizando os movimento acima e abaixo
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Fugir do alvo
  #     target : alvo
  #--------------------------------------------------------------------------
  def move_away_from_target(target)
    sx = @x - target.x
    sy = @y - target.y
    # Se as coordenadas forem iguais
    return if sx == 0 and sy == 0
    abs_sx = sx.abs
    abs_sy = sy.abs
    # Se as distâncias vertical e horizontal forem as mesmas
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # Se a distância horizontal for a mais longínqua
    if abs_sx > abs_sy
      # Fugir do alvo, priorizando os movimento direita e esquerda
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # Se a distância vertical for a mais longínqua
    else
      # Fugir do alvo, priorizando os movimento acima e abaixo
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    if jumping?
      update_jump
    elsif moving?
      update_move
    else
      update_stop
    end
    if @anime_count > 18 - @move_speed * 2
      # Se parar a animação estiver OFF durante a parada
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      # Se parar a animação estiver ON durante a parada
      else
        @pattern = (@pattern + 1) % 4
      end
      @anime_count = 0
    end
    update_graphic_animation
    # Se estiver esperando
    if @wait_count > 0
      @wait_count -= 1
      return
    end
    # Se for uma rota pré-definida
    if @move_route_forcing
      move_type_custom
      return
    end
    # Quando estiver esperando a execução de um evento ou for fixo
    return if @starting or lock?
  end
  #--------------------------------------------------------------------------
  # * Atualização do gráfico da animação
  #--------------------------------------------------------------------------
  def update_graphic_animation
    return if @attack_delay == 20
    @attack_delay += 1
    @pattern = (@attack_delay / 5).to_i
    if @attack_delay == 20
      @character_name = @old_character_name
      @pattern = @old_pattern
      @step_anime = @old_anime
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização dos status
  #--------------------------------------------------------------------------
  def update_states
    for i in @actor.states
      next if !STATES[i] or STATES[i] == 0
      if @state_time <= STATES[i] * 40
        @state_time += 1
        # Causar dano
        @actor.slip_damage_effect if @actor.hp > 0 and @actor.slip_damage? and Graphics.frame_count % 40 == 0
      else
        @actor.remove_state(i)
        @state_time = 0
      end
    end
  end
end

#==============================================================================
# ** Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  alias diamond_abs_initialize initialize
  alias diamond_abs_refresh refresh
  alias diamond_abs_update update
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :event                    # evento
  attr_reader   :erased                   # ocultado
  attr_reader   :hate_group               # grupo de ódio
  attr_accessor :target                   # alvo
  #--------------------------------------------------------------------------
  # * Inicialização de objetos
  #     map_id : ID do mapa
  #     event  : evento
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    clear_enemy
    diamond_abs_initialize(map_id, event)
  end
  #--------------------------------------------------------------------------
  # * Parâmetros da lista
  #     size    : tamanho
  #     comment : comentário
  #--------------------------------------------------------------------------
  def list_parameters(size, comment)
    return nil unless @page.list
    @page.list.each_with_index do |item, i|
      # Se não for um comentário
      next unless item.code == 108
      next unless item.parameters[0].include?(comment)
      parameters = []
      for id in i...(i + size)
        parameters << list[id].parameters[0] if list[id]
      end
      return parameters
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # * Atualizar
  #--------------------------------------------------------------------------
  def refresh
    diamond_abs_refresh
    # Salvar velocidade e frequência originais
    @old_speed = @move_speed
    @old_frequency = @move_frequency
    # Se alguma página não completar as condições do evento
    unless @page
      clear_enemy
      return
    end
    parameters = list_parameters(8, 'Enemy')
    # Se a página não tiver parâmetros
    unless parameters
      clear_enemy
      return
    end
    enemy_id = parameters[0].split[1].to_i
    # Não resetar o HP e o SP do inimigo, cujo ID não mudou, quando chamar o need_refresh
    return if actor? and @enemy_id == enemy_id
    @enemy_id = enemy_id
    # Se o inimigo estiver renascendo
    return if @respawn
    # Inimigo
    @actor = Game_Enemy.new(@enemy_id, @id)
    # Comportamento
    @behavior = parameters[1].split[1].to_i
    # Alcance da visão
    @sight = parameters[2].split[1].to_i
    # Grupo de ódio
    @hate_group = eval(parameters[3].split[1])
    # Velocidade do ataque
    @aggressiveness = parameters[4].split[1].to_i
    # Velocidade do movimento
    @speed = parameters[5].split[1].to_i
    # Frequência do movimento
    @frequency = parameters[6].split[1].to_i
    # Trigger
    @trg = [parameters[7].split[1].to_i, parameters[7].split[2]]
  end
  #--------------------------------------------------------------------------
  # * Limpar inimigo
  #--------------------------------------------------------------------------
  def clear_enemy
    @enemy_id = 0
    #@respawn = nil
    @actor = nil
    @target = nil
  end
  #--------------------------------------------------------------------------
  # * Definição da posição inicial
  #--------------------------------------------------------------------------
  def set_start_position
    loop do
      new_x = rand($game_map.width)
      new_y = rand($game_map.height)
      if $game_map.passable?(new_x, new_y, 0)
        moveto(new_x, new_y)
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Matar inimigo
  #--------------------------------------------------------------------------
  def kill
    #return if @respawn
    @respawn = RESPAWN_TIME * 40
    treasure if @target.is_a?(Game_Player)
    @target = nil
    @actor = nil
    desactive_enemy
  end
  #--------------------------------------------------------------------------
  # * Ocultar inimigo
  #--------------------------------------------------------------------------
  def desactive_enemy
    case @trg[0]
    when 0 # Ocultar temporariamente
      erase
    when 1 # Switche
      $game_switches[@trg[1].to_i] = !$game_switches[@trg[1].to_i]
    when 2 # Variável
      $game_variables[@trg[1].to_i] += 1
    when 3 # Switche local
      $game_self_switches[[@map_id, @event.id, @trg[1]]] = true
    end
    $game_map.need_refresh = true unless @erased
  end
  #--------------------------------------------------------------------------
  # * Tesouro do inimigo
  #--------------------------------------------------------------------------
  def treasure
    return unless actor?
    # Se pode ganhar experiência
    unless $game_party.actors[0].cant_get_exp?
      $game_party.actors[0].damage = "#{@actor.exp} Exp"
      $game_party.actors[0].exp += @actor.exp
    end
    if (gold = rand(@actor.gold)) > 0
      $game_party.gain_gold(gold)
      $game_player.reward = gold if GOLD_ICON.empty?
    end
    # Probabilidade do tesouro
    if rand(100) < @actor.treasure_prob
      if $game_drop.size >= MAX_MAP_DROPS
        $game_party.gain_item(@actor.item_id, 1) if @actor.item_id > 0
        $game_party.gain_weapon(@actor.weapon_id, 1) if @actor.weapon_id > 0
        $game_party.gain_armor(@actor.armor_id, 1) if @actor.armor_id > 0
      else
        $game_drop << Game_Drop.new(@actor.item_id, 0, 1, @x, @y) if @actor.item_id > 0
        $game_drop << Game_Drop.new(@actor.weapon_id, 1, 1, @x, @y) if @actor.weapon_id > 0
        $game_drop << Game_Drop.new(@actor.armor_id, 2, 1, @x, @y) if @actor.armor_id > 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Renascimento do inimigo
  #--------------------------------------------------------------------------
  def respawn
    @respawn = nil
    active_enemy
    # Mover para a posição aleatória
    set_start_position
  end
  #--------------------------------------------------------------------------
  # * Mostrar inimigo
  #--------------------------------------------------------------------------
  def active_enemy
    # Oculto
    if @erased
      @erased = false
      refresh
    # Switche local
    elsif @trg[0] == 3
      $game_self_switches[[@map_id, @event.id, @trg[1]]] = false
      $game_map.need_refresh = true
    end
    # Forçar atualização para tornar igual as coordenadas do sprite do evento com às desta classe
    $game_temp.need_update = true if @trg[0] > 0
  end
  #--------------------------------------------------------------------------
  # * Definição da ação
  #--------------------------------------------------------------------------
  def make_action
    for action in @actor.actions
      # Se o evento estiver ocorrendo
      next if $game_system.map_interpreter.running?
      # Se não atender as condições de HP
      next if @actor.hp * 100.0 / @actor.maxhp > action.condition_hp
      # Se não atender as condições de nível
      next if $game_party.max_level < action.condition_level
      # Se não atender as condições de switch
      next if action.condition_switch_id > 0 and $game_switches[action.condition_switch_id] == false
      # Se não atender a frequência
      next if action.rating < rand(11)
      # Se não atender a condição de tempo
      next if Graphics.frame_count % (@aggressiveness * ATTACK_TIME) != 0
      # Limpar ação atual se o inimigo não for defender
      @actor.current_action.basic = 3 if action.basic != 1
      # Ações
      case action.kind
      when 0 # Fundamentais
        case action.basic
        when 0 # Atacar
          attack_normal
        when 1 # Defender
          defend
        when 2 # Fugir
          if @target
            move_away_from_target(@target)
          else
            move_away_from_player
          end
        end
      when 1 # Habilidades
        attack_skill(action.skill_id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque normal
  #--------------------------------------------------------------------------
  def attack_normal
    # Se não tiver alvo, o inimigo não irá atacar, mesmo que o herói esteja na frente do inimigo
    return unless @target
    # Se for impossível atacar
    return if @actor.restriction == 4
    return unless in_front?(@target)
    animate_attack('_melee')
    if @target.is_a?(Game_Player)
      hit_player(@actor.animation2_id)
    elsif @target.is_a?(Game_Event)
      # Se o alvo já morreu
      if !@target.actor? or @target.actor.dead?
        @target = nil
      else
        hit_enemy(@target, @actor.animation2_id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  def attack_skill(skill_id)
    skill = $data_skills[skill_id]
    # Se não é possível utilizar a habilidade
    return unless @actor.skill_can_use?(skill_id)
    # Se não tiver alvo
    return unless @target
    # Se o inimigo morreu
    return if @target.is_a?(Game_Event) and (!@target.actor? or @target.actor.dead?)
    # Alvos que afeta
    case skill.scope
    when 1 # Herói
      # Se a habilidade ataca à distância
      if RANGE_SKILLS.has_key?(skill_id)
        return unless in_direction?(@target)
        skill_attack_range(skill)
      # Se é um explosivo de longo alcance
      elsif RANGE_EXPLODE.has_key?(skill_id)
        return unless in_direction?(@target)
        skill_explode_range(skill)
      # Se a habilidade ataca em área
      elsif AREA_SKILLS.has_key?(skill_id)
        return unless in_range?(@target, AREA_SKILLS[skill_id])
        skill_attack_area(skill)
      else
        return unless in_front?($game_player)
        skill_attack_normal(skill)
      end
    when 3..7 # Inimigo
      skill_recover(skill)
    end
    @actor.sp -= skill.sp_cost
    @animation_id = skill.animation1_id if skill.animation1_id > 0 and skill.animation2_id == 0
    $game_temp.common_event_id = skill.common_event_id if skill.common_event_id > 0
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade normal
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_attack_normal(skill)
    animate_attack(SKILL_ANIMATION[skill.id]) if SKILL_ANIMATION.has_key?(skill.id)
    #return unless @target
    if @target.is_a?(Game_Player)
      hit_player(skill.animation2_id, skill.id)
    else
      # Se o alvo já morreu
      if !@target.actor? or @target.actor.dead?
        @target = nil
      else
        hit_enemy(@target, skill.animation2_id, skill.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade em área
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_attack_area(skill)
    animate_attack(SKILL_ANIMATION[skill.id]) if SKILL_ANIMATION.has_key?(skill.id)
    hit_player(skill.animation2_id, skill.id) if in_range?($game_player, AREA_SKILLS[skill.id])
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead? or event == self
      next unless in_range?(event, AREA_SKILLS[skill.id])
      hit_enemy(event, skill.animation2_id, skill.id)
    end
  end
  #--------------------------------------------------------------------------
  # * Defender
  #--------------------------------------------------------------------------
  def defend
    animate_attack('_defend')
    @actor.current_action.basic = 1
  end
  #--------------------------------------------------------------------------
  # * Bater no herói
  #     animation : animação
  #     skill_id  : ID da habilidade
  #--------------------------------------------------------------------------
  def hit_player(animation, skill_id = 0)
    if skill_id > 0
      $game_party.actors[0].skill_effect(@actor, $data_skills[skill_id])
    else
      $game_party.actors[0].attack_effect(@actor)
    end
    $game_player.animation_id = animation if animation > 0
  end
  #--------------------------------------------------------------------------
  # * Bater no inimigo
  #     event     : evento
  #     animation : animação
  #     skill_id  : ID da habilidade
  #--------------------------------------------------------------------------
  def hit_enemy(event, animation, skill_id = 0)
    event.target = self if event.hate_group[0] > 0 and event.hate_group[1] == @hate_group[0]
    if skill_id > 0
      event.actor.skill_effect(@actor, $data_skills[skill_id])
    else
      event.actor.attack_effect(@actor)
    end
    event.animation_id = animation if animation > 0 and $game_map.in_screen?(event)
  end
  #--------------------------------------------------------------------------
  # * Atualização de movimento
  #--------------------------------------------------------------------------
  def update_self_movement
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      # Se não tiver alvo ou o alvo estiver fora do alcance
      if !@target or !in_range?(@target, @sight) and actor?
        # Limpar alvo fora do alcance se o herói não estiver nele
        @target = in_range?($game_player, @sight) ? $game_player : nil
        find_enemy_hate_group
      end
      # Se o inimigo estiver dentro do alcance
      if actor? and @target
        @move_speed = @speed
        @move_frequency = @frequency
        # Comportamento do inimigo
        case @behavior
        when 1 # Fugir do alvo
          move_away_from_target(@target)
        when 2 # Seguir alvo
          move_toward_target(@target)
        end
      else
        @target = nil
        # Resetar movimento se o inimigo se transformar em evento
        @move_speed = @old_speed
        @move_frequency = @old_frequency
        # Ramificação pelo tipo de movimento
        case @move_type
        when 1  # Aleatório
          move_type_random
        when 2  # Seguir herói
          move_type_toward_player
        when 3  # Pré-definido
          move_type_custom
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Procurar inimigo do grupo de ódio
  #--------------------------------------------------------------------------
  def find_enemy_hate_group
    return if @hate_group[0] == 0
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead?
      if event.hate_group[0] > 0 and event.hate_group[1] == @hate_group[0]
        if in_range?(event, @sight)
          @target = event
          break
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    diamond_abs_update
    @respawn -= 1 if @respawn and @respawn > 0
    if actor? and @target and !@actor.dead?
      make_action
    elsif actor? and @actor.dead?
      kill
    elsif !actor? and @respawn and @respawn <= 0
      respawn
    end
    # Aqui o alvo só é zerado depois que o inimigo desaparecer
    update_self_movement
    update_states if actor? and !@actor.dead?
  end
end

#==============================================================================
# ** Game_Player
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  alias diamond_abs_refresh refresh
  alias diamond_abs_update update
  #--------------------------------------------------------------------------
  # * Inicialização de objetos
  #--------------------------------------------------------------------------
  def initialize
    super
    @weapon_attack_time = 0
    @skill_attack_time = 0
    @recover_time = 0
  end
  #--------------------------------------------------------------------------
  # * Ataque do herói
  #--------------------------------------------------------------------------
  def update_attack
    @weapon_attack_time -= 1 if @weapon_attack_time > 0
    return if @weapon_attack_time > 0
    # Se não for impossível atacar
    if Input.press?(ATTACK_KEY) and @actor.weapon_id > 0 and @actor.restriction != 4
      @weapon_attack_time = COOLDOWN_WEAPONS.has_key?(@actor.weapon_id) ? COOLDOWN_WEAPONS[@actor.weapon_id] : ATTACK_TIME
      if RANGE_WEAPONS.has_key?(@actor.weapon_id)
        attack_range
      else
        attack_normal
      end
    end
    if Input.press?(DEFEND_KEY) and @actor.armor1_id > 0
      @weapon_attack_time = ATTACK_TIME
      defend
    else
      @actor.current_action.basic = 3
    end
  end
  #--------------------------------------------------------------------------
  # * Atalhos
  #--------------------------------------------------------------------------
  def update_hotkeys
    @skill_attack_time -= 1 if @skill_attack_time > 0
    return if @skill_attack_time > 0
    for key in @actor.hotkeys.keys
      next if !@actor.hotkeys[key] or @actor.hotkeys[key] == 0
      next unless Input.trigger?(key)
      @skill_attack_time = COOLDOWN_SKILL
      # Se for uma habilidade
      if @actor.hotkeys[key] > 0
        attack_skill(@actor.hotkeys[key])
      else
        use_item(@actor.hotkeys[key].abs)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque normal
  #--------------------------------------------------------------------------
  def attack_normal
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead? or !in_front?(event)
      animate_attack(MELEE_ANIMATION[@actor.weapon_id]) if MELEE_ANIMATION.has_key?(@actor.weapon_id)
      hit_enemy(event, $data_weapons[@actor.weapon_id].animation2_id)
      break
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque à distância
  #--------------------------------------------------------------------------
  def attack_range
    return if $game_party.item_number(RANGE_WEAPONS[@actor.weapon_id][1]) == 0
    $game_party.lose_item(RANGE_WEAPONS[@actor.weapon_id][1], 1)
    projectile_name, item_id, animation_id, speed, range, animation, sufix = RANGE_WEAPONS[@actor.weapon_id]
    animate_attack(sufix) if sufix
    $game_range << Game_Range.new(self, projectile_name, animation_id, speed, range, animation)
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade
  #     skill_id : ID da habilidade
  #--------------------------------------------------------------------------
  def attack_skill(skill_id)
    skill = $data_skills[skill_id]
    # Se o herói não possui a habilidade
    return unless @actor.skills.include?(skill_id)
    # Se não é possível utilizar a habilidade
    return unless @actor.skill_can_use?(skill_id)
    # Alvos que afeta
    case skill.scope
    when 1 # Inimigo
      # Se a habilidade ataca à distância
      if RANGE_SKILLS.has_key?(skill_id)
        skill_attack_range(skill)
      # Se é um explosivo de longo alcance
      elsif RANGE_EXPLODE.has_key?(skill_id)
        skill_explode_range(skill)
      # Se a habilidade ataca em área
      elsif AREA_SKILLS.has_key?(skill_id)
        skill_attack_area(skill)
      else
        skill_attack_normal(skill)
      end
    when 2 # Todos os inimigos
      skill_attack_all(skill)
    when 3..7 # Herói e aliados
      skill_recover(skill)
    end
    @actor.sp -= skill.sp_cost
    @animation_id = skill.animation1_id if skill.animation1_id > 0 and skill.animation2_id == 0
    $game_temp.common_event_id = skill.common_event_id if skill.common_event_id > 0
    #$game_system.se_play(skill.menu_se)
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade normal
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_attack_normal(skill)
    animate_attack(SKILL_ANIMATION[skill.id]) if SKILL_ANIMATION.has_key?(skill.id)
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead? or !in_front?(event)
      hit_enemy(event, skill.animation2_id, skill.id)
      break
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade que ataca todos os inimigos
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_attack_all(skill)
    animate_attack(SKILL_ANIMATION[skill.id]) if SKILL_ANIMATION.has_key?(skill.id)
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead?
      hit_enemy(event, skill.animation2_id, skill.id)
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque com habilidade em área
  #     skill : habilidade
  #--------------------------------------------------------------------------
  def skill_attack_area(skill)
    animate_attack(SKILL_ANIMATION[skill.id]) if SKILL_ANIMATION.has_key?(skill.id)
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead? or !in_range?(event, AREA_SKILLS[skill.id])
      hit_enemy(event, skill.animation2_id, skill.id)
    end
  end
  #--------------------------------------------------------------------------
  # * Defender
  #--------------------------------------------------------------------------
  def defend
    animate_attack(DEFEND_ANIMATION[@actor.armor1_id]) if DEFEND_ANIMATION.has_key?(@actor.armor1_id)
    @actor.current_action.basic = 1
  end
  #--------------------------------------------------------------------------
  # * Usar item
  #     item_id : ID do item
  #--------------------------------------------------------------------------
  def use_item(item_id)
    item = $data_items[item_id]
    # Se o item for usável
    if $game_party.item_can_use?(item.id)
      # Alvos que afeta
      case item.scope
      when 1 # Inimigo
        item_attack_normal(item)
      when 2 # Todos os inimigos
        item_attack_all(item)
      when 3..7 # Herói
        item_recover(item)
      end
      $game_system.se_play(item.menu_se)
      $game_party.lose_item(item.id, 1) if item.consumable
      @animation_id = item.animation1_id if item.animation1_id > 0
      $game_temp.common_event_id = item.common_event_id if item.common_event_id > 0
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque com item normal
  #     item : item
  #--------------------------------------------------------------------------
  def item_attack_normal(item)
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead? or !in_front?(event)
      event.actor.item_effect(item)
      event.animation_id = item.animation2_id if item.animation2_id > 0
      break
    end
  end
  #--------------------------------------------------------------------------
  # * Ataque com item que afeta todos os inimigos
  #     item : item
  #--------------------------------------------------------------------------
  def item_attack_all(item)
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead?
      event.actor.item_effect(item)
      event.animation_id = item.animation2_id if item.animation2_id > 0
    end
  end
  #--------------------------------------------------------------------------
  # * Item de recuperação
  #     item : item
  #--------------------------------------------------------------------------
  def item_recover(item)
    @actor.item_effect(item)
  end
  #--------------------------------------------------------------------------
  # * Bater no inimigo
  #     event     : evento
  #     animation : animação
  #     skill_id  : ID da habilidade
  #--------------------------------------------------------------------------
  def hit_enemy(event, animation, skill_id = 0)
    event.target = self
    if skill_id > 0
      event.actor.skill_effect(@actor, $data_skills[skill_id])
    else
      event.actor.attack_effect(@actor)
    end
    event.animation_id = animation if animation > 0 and $game_map.in_screen?(event)
  end
  #--------------------------------------------------------------------------
  # * Atualizar
  #--------------------------------------------------------------------------
  def refresh
    @actor = $game_party.actors[0]
    diamond_abs_refresh
  end
  #--------------------------------------------------------------------------
  # * Recuperação automática
  #--------------------------------------------------------------------------
  def auto_recovery
    @recover_time += 1
    if @recover_time == RECOVER_TIME * 40
      @actor.hp += (@actor.agi / 100).next * RECOVER_HP if @actor.hp != @actor.maxhp
      @actor.sp += (@actor.agi / 100).next * RECOVER_SP if @actor.sp != @actor.maxsp
      @recover_time = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    diamond_abs_update
    update_attack
    update_hotkeys
    update_states
    auto_recovery
    $game_temp.gameover = true if @actor.dead?
  end
end

#==============================================================================
# ** Game_Range
#==============================================================================
class Game_Range
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :picture_name             # imagem
  attr_reader   :step_anime               # animação de movimento
  attr_reader   :x                        # coordenada x
  attr_reader   :y                        # coordenada y
  attr_reader   :real_x                   # coordenada x (real / 32)
  attr_reader   :real_y                   # coordenada y (real / 32)
  attr_reader   :pattern                  # molde
  attr_reader   :angle                    # ângulo
  attr_reader   :destroy                  # flag: destruído
  attr_accessor :draw                     # flag: desenhado
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #     parent        : 
  #     picture_name  : gráfico
  #     animation     : animação
  #     move_speed    : velocidade do movimento
  #     range         : alcance
  #     step_anime    : animação
  #     skill_id      : ID da habilidade
  #     range_explode : alcance da explosão
  #--------------------------------------------------------------------------
  def initialize(parent, picture_name, animation, move_speed, range, step_anime, skill_id = 0, range_explode = 0)
    @direction = parent.direction
    @animation = animation
    @move_speed = move_speed
    @start_x = parent.x
    @start_y = parent.y
    @x = @start_x
    @y = @start_y
    @range = range
    @picture_name = picture_name
    @step_anime = step_anime
    @skill_id = skill_id
    @range_explode = range_explode
    @event = parent if parent.is_a?(Game_Event)
    @anime_count = 0
    @pattern = 0
    @destroy = false
    @draw = false
    case @direction
    when 2 # Abaixo
      @angle = 0
      @y += 1
    when 4 # Esquerda
      @angle = 270
      @x -= 1
    when 6 # Direta
      @angle = 90
      @x += 1
    when 8 # Acima
      @angle = 180
      @y -= 1
    end
    @real_x = @x * 128
    @real_y = @y * 128
  end
  #--------------------------------------------------------------------------
  # * Explosão
  #     user : usuário
  #--------------------------------------------------------------------------
  def explode(user)
    user.hit_player($data_skills[@skill_id].animation2_id, @skill_id) if @event and user.in_range?($game_player, @range_explode)
    for event in $game_map.events.values
      next if !event.actor? or event.actor.dead? or event == user or !user.in_range?(event, @range_explode)
      user.hit_enemy(event, $data_skills[@skill_id].animation2_id, @skill_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    #return if @destroy
    if @step_anime
      @anime_count += 1
      if @anime_count > 18 - @move_speed * 2
        @pattern = (@pattern + 1) % 4
        @anime_count = 0
      end
    end
    unless $game_map.passable?(@x, @y, 0)
      @destroy = true
      return
    end
    # Se o projétil foi lançado por um inimigo
    if @event && @x == $game_player.x and @y == $game_player.y
      # Se o inimigo que lançou o projétil não morreu
      if @event.actor? and !@event.actor.dead?
        if @range_explode > 0
          explode(@event)
        else
          @event.hit_player(@animation, @skill_id)
        end
      end
      @destroy = true
      return
    end
    for event in $game_map.events.values
      # Se o evento estiver oculto temporariamente ou atravessar estiver ON
      next if event.erased or @x != event.x or @y != event.y or event.through
      # Se for um inimigo
      if event.actor? and !event.actor.dead?
        # Se o projétil foi lançado por um inimigo
        if @event
          # Se o inimigo que lançou o projétil já morreu
          if !@event.actor? or @event.actor.dead?
            event.target = nil if event.target == @event
            @destroy = true
            return
          end
          if @range_explode > 0
            explode(@event)
          else
            @event.hit_enemy(event, @animation, @skill_id)
          end
        else
          if @range_explode > 0
            explode($game_player)
          else
            $game_player.hit_enemy(event, @animation, @skill_id)
          end
        end
      end
      @destroy = true
      return
    end
    # Se ultrapassar o alcance
    if @x > @start_x + @range or @x + @range < @start_x or
      @y > @start_y + @range or @y + @range < @start_y
      @destroy = true
      return
    end
    # Atualizar coordenadas (deixe aqui embaixo)
    @x += (@direction == 4 ? -1 : @direction == 6 ? 1 : 0)
    @y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    @real_x = @x * 128
    @real_y = @y * 128
  end
end

#==============================================================================
# ** Game_Drop
#==============================================================================
class Game_Drop
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :kind                     # tipo
  attr_reader   :x                        # coordenada x
  attr_reader   :y                        # coordenada y
  attr_reader   :real_x                   # coordenada x (real / 32)
  attr_reader   :real_y                   # coordenada y (real / 32)
  attr_reader   :destroy                  # flag: destruído
  attr_accessor :draw                     # flag: desenhado
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #     id     : ID
  #     kind   : tipo
  #     amount : quantidade
  #     x      : coordenada x
  #     y      : coordenada y
  #     map    : ID do mapa
  #     time   : tempo
  #--------------------------------------------------------------------------
  def initialize(id, kind, amount, x, y, map = $game_map.map_id, time = 0)
    @id = id
    @kind = kind
    @amount = amount
    @x = x
    @y = y
    @time = time
    # Aqui é utilizado -1, pois 0 é a posição inicial do mapa
    @real_x = @x * 128 #if @character.x > -1
    @real_y = @y * 128 #if @character.y > -1
    @destroy = false
    @draw = false
  end
  #--------------------------------------------------------------------------
  # * Obter recompensa
  #--------------------------------------------------------------------------
  def get_reward
    $game_system.se_play($data_system.decision_se)
    case @kind
    when 0
      $game_party.gain_item(@id, @amount)
    when 1
      $game_party.gain_weapon(@id, @amount)
    when 2
      $game_party.gain_armor(@id, @amount)
    end
    @destroy = true
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    @time += 1
    @destroy = (@time >= DROP_DESPAWN_TIME * 40)
  end
end

#==============================================================================
# ** Sprite_Character
#==============================================================================
class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  alias diamond_abs_sprite_initialize initialize
  alias diamond_abs_update update
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #     viewport  : ponto de vista
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    @_reward_duration = 0
    diamond_abs_sprite_initialize(viewport, character)
  end
  #--------------------------------------------------------------------------
  # * Exibição do HP
  #--------------------------------------------------------------------------
  def dispose_display_hp
    return unless @_hp_display
    @_hp_display.bitmap.dispose
    @_hp_display.dispose
    @_hp_display = nil
  end
  #--------------------------------------------------------------------------
  # * Exibição da recompensa
  #--------------------------------------------------------------------------
  def dispose_reward
    return unless @_reward_sprite
    @_reward_sprite.bitmap.dispose
    @_reward_sprite.dispose
    @_reward_sprite = nil
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    diamond_abs_update
    # Se o actor morreu ou o status foi removido
    if !@character.actor? or @character.actor.state_animation_id == 0 and @state_animation_id
      @state_animation_id = nil
      loop_animation(nil)
    elsif @character.actor?
      if @character.actor.damage
        damage(@character.actor.damage, @character.actor.critical) if $game_map.in_screen?(@character)
        @character.actor.damage = nil
        # Garante que o crítico esteja sempre falso ao receber novos danos
        @character.actor.critical = false
      elsif @character.actor.state_animation_id > 0 and @character.actor.state_animation_id != @state_animation_id
        @state_animation_id = @character.actor.state_animation_id
        loop_animation($data_animations[@state_animation_id])
      end
    end
    if @character.actor? and @character.actor.hp < @character.actor.maxhp
      update_display_hp if !@_hp_display or @character.actor.hp != @old_hp
      @_hp_display.x = self.x
      @_hp_display.y = self.y - self.oy / 2 - 24
    else
      dispose_display_hp
    end
    if @character.reward
      reward(@character.reward)
      @character.reward = nil
    end
    if @_damage_duration > 0
      @_damage_sprite.x = self.x
      @_damage_sprite.y = self.y
      @_damage_sprite.opacity -= 5
    end
    if @_reward_duration > 0
      @_reward_sprite.x = self.x
      @_reward_sprite.y = self.y - self.oy / 2 - (20 - @_reward_duration)
      @_reward_duration -= 1
    else
      dispose_reward
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do HP
  #--------------------------------------------------------------------------
  def update_display_hp
    @old_hp = @character.actor.hp
    bitmap = RPG::Cache.picture('HPBar')
    if @_hp_display
      @_hp_display.bitmap.clear
    else
      @_hp_display = Sprite.new(self.viewport)
      @_hp_display.bitmap = Bitmap.new(bitmap.width, bitmap.height / 2)
      @_hp_display.ox = bitmap.width / 2
      @_hp_display.oy = (@ch == 100 ? -76 : -50)
      @_hp_display.z = 2999
    end
    @_hp_display.bitmap.blt(0, 0, bitmap, @_hp_display.bitmap.rect)
    @_hp_display.bitmap.blt(0, 0, bitmap, Rect.new(0, 4, bitmap.width * @old_hp / @character.actor.maxhp, 4))
  end
  #--------------------------------------------------------------------------
  # * Dano
  #     value    : valor
  #     critical : crítico
  #--------------------------------------------------------------------------
  def damage(value, critical)
    dispose_damage
    @_damage_sprite = Sprite.new(self.viewport)
    @_damage_sprite.bitmap = Bitmap.new(160, 48)
    @_damage_sprite.bitmap.font.name = DAMAGE_FONT_NAME
    @_damage_sprite.bitmap.font.bold = DAMAGE_FONT_BOLD
    @_damage_sprite.bitmap.font.size = DAMAGE_FONT_SIZE
    if critical
      @_damage_sprite.bitmap.font.color = Color.new(0, 0, 0)
      @_damage_sprite.bitmap.draw_text(- 1, 0, @_damage_sprite.bitmap.width, 36, DAMAGE_TEXTS[1], 1)
      @_damage_sprite.bitmap.draw_text(1, 0, @_damage_sprite.bitmap.width, 36, DAMAGE_TEXTS[1], 1)
      @_damage_sprite.bitmap.draw_text(- 1, 2, @_damage_sprite.bitmap.width, 36, DAMAGE_TEXTS[1], 1)
      @_damage_sprite.bitmap.draw_text(1, 2, @_damage_sprite.bitmap.width, 36, DAMAGE_TEXTS[1], 1)
      @_damage_sprite.bitmap.font.color = DAMAGE_COLORS[0]
      @_damage_sprite.bitmap.draw_text(0, 1, @_damage_sprite.bitmap.width, 36, DAMAGE_TEXTS[1], 1)
    else
      damage_string = value.is_a?(Numeric) ? value.abs.to_s : value.to_s
      @_damage_sprite.bitmap.font.color = Color.new(0, 0, 0)
      @_damage_sprite.bitmap.draw_text(- 1, 0, @_damage_sprite.bitmap.width, 36, damage_string, 1)
      @_damage_sprite.bitmap.draw_text(1, 0, @_damage_sprite.bitmap.width, 36, damage_string, 1)
      @_damage_sprite.bitmap.draw_text(- 1, 2, @_damage_sprite.bitmap.width, 36, damage_string, 1)
      @_damage_sprite.bitmap.draw_text(1, 2, @_damage_sprite.bitmap.width, 36, damage_string, 1)
      # Dano
      if value.is_a?(Numeric) and value.to_i >= 0
        @_damage_sprite.bitmap.font.color = DAMAGE_COLORS[1]
      # Cura
      elsif value.is_a?(Numeric) and value.to_i < 0
        @_damage_sprite.bitmap.font.color = DAMAGE_COLORS[2]
      # Errou
      elsif damage_string == DAMAGE_TEXTS[0]
        @_damage_sprite.bitmap.font.color = DAMAGE_COLORS[3]
      # Subiu nível
      elsif damage_string == DAMAGE_TEXTS[2]
        @_damage_sprite.bitmap.font.color = DAMAGE_COLORS[5]
      # Experiência
      else
        @_damage_sprite.bitmap.font.color = DAMAGE_COLORS[4]
      end
      @_damage_sprite.bitmap.draw_text(0, 1, @_damage_sprite.bitmap.width, 36, damage_string, 1)
    end
    @_damage_sprite.ox = 70
    @_damage_sprite.oy = 80
    @_damage_sprite.x = self.x
    @_damage_sprite.y = self.y
    @_damage_sprite.z = 3000
    @_damage_duration = 30
  end
  #--------------------------------------------------------------------------
  # * Recompensa
  #     value : valor
  #--------------------------------------------------------------------------
  def reward(value)
    dispose_reward
    @_reward_sprite = Sprite.new(self.viewport)
    @_reward_sprite.bitmap = Bitmap.new(24, 24)
    @_reward_sprite.bitmap.font.name = 'Tahoma'
    @_reward_sprite.bitmap.font.size = 12
    @_reward_sprite.bitmap.font.color = Color.new(255, 255, 0)
    @_reward_sprite.bitmap.blt(0, 0, RPG::Cache.icon(GOLD_ICON), Rect.new(0, 0, 24, 24))
    @_reward_sprite.bitmap.draw_text(0, 10, @_reward_sprite.bitmap.width, @_reward_sprite.bitmap.font.size + 2, value.to_s, 1)
    @_reward_sprite.ox = 0
    @_reward_sprite.oy = 20
    @_reward_sprite.x = self.x
    @_reward_sprite.y = self.y - self.oy / 2
    @_reward_sprite.z = 3000
    @_reward_duration = 20
  end
end

#==============================================================================
# ** Sprite_Range
#==============================================================================
class Sprite_Range < Sprite
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :character                # 
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #     viewport  : ponto de vista
  #     character : 
  #--------------------------------------------------------------------------
  def initialize(viewport, character)
    super(viewport)
    @character = character
    self.bitmap = RPG::Cache.projectiles(@character.picture_name)
    self.angle = @character.angle
    @width = @character.step_anime ? bitmap.width / 4 : bitmap.width
    self.ox = @width / 2
    self.oy = bitmap.height
    update
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    super
    self.x = (@character.real_x - $game_map.display_x + 3) / 4 + 16
    self.y = (@character.real_y - $game_map.display_y + 3) / 4 + 16
    self.src_rect.set(@character.pattern * @width, 0, @width, bitmap.height)
  end
end

#==============================================================================
# ** Sprite_Drop
#==============================================================================
class Sprite_Drop < Sprite
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :character                # 
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #     viewport  : ponto de vista
  #     character : 
  #--------------------------------------------------------------------------
  def initialize(viewport, character)
    super(viewport)
    @character = character
    case @character.kind
    when 0
      self.bitmap = RPG::Cache.icon($data_items[@character.id].icon_name)
    when 1
      self.bitmap = RPG::Cache.icon($data_weapons[@character.id].icon_name)
    when 2
      self.bitmap = RPG::Cache.icon($data_armors[@character.id].icon_name)
    end 
    update
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    super
    self.x = (@character.real_x - $game_map.display_x) / 4
    self.y = (@character.real_y - $game_map.display_y) / 4
  end
end

#==============================================================================
# ** Sprite_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  alias diamond_abs_initialize initialize
  alias diamond_abs_dispose dispose
  #--------------------------------------------------------------------------
  # * Inicialização dos objetos
  #--------------------------------------------------------------------------
  def initialize
    @range_sprites = []
    @drop_sprites = []
    diamond_abs_initialize
  end
  #--------------------------------------------------------------------------
  # * Exibição
  #--------------------------------------------------------------------------
  def dispose
    diamond_abs_dispose
    @range_sprites.compact.each { |i| i.dispose }
    $game_range.compact.each { |i| i.draw = false }
    @drop_sprites.compact.each { |i| i.dispose }
    $game_drop.compact.each { |i| i.draw = false }
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    if @panorama_name != $game_map.panorama_name or
      @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue) if @panorama_name != ''
      Graphics.frame_reset
    end
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue) if @fog_name != ''
      Graphics.frame_reset
    end
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    update_characters
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    for sprite in @picture_sprites
      sprite.update
    end
    @timer_sprite.update
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    @viewport3.color = $game_screen.flash_color
    @viewport1.update
    @viewport3.update
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update_characters
    for range in @range_sprites.compact
      if range.character.destroy or range.disposed?
        range.dispose
        @range_sprites.delete(range)
        $game_range.delete(range.character)
      else
        range.update if $game_map.in_screen?(range.character)
      end
    end
    for range in $game_range.compact
      if range.draw
        # Atualizar independetemente de proximidade com o herói
        range.update
      else
        @range_sprites << Sprite_Range.new(@viewport1, range)
        range.draw = true
      end
    end
    for drop in @drop_sprites.compact
      if drop.character.destroy or drop.disposed?
        drop.dispose
        @drop_sprites.delete(drop)
        $game_drop.delete(drop.character)
      else
        drop.update if $game_map.in_screen?(drop.character)
      end
    end
    for drop in $game_drop.compact
      if drop.draw
        if Input.trigger?(Input::C) && drop.x == $game_player.x and drop.y == $game_player.y
          drop.get_reward
          break
        end
        drop.update
      else
        @drop_sprites << Sprite_Drop.new(@viewport1, drop)
        drop.draw = true
      end
    end
    # Deixe aqui no fim do procedimento
    for sprite in @character_sprites
      # Se o character estiver no alcance do herói ou a atualização é forçada
      sprite.update if $game_map.in_screen?(sprite.character) or $game_temp.need_update
    end
    $game_temp.need_update = false
  end
end

#==============================================================================
# ** Interpreter
#==============================================================================
class Interpreter
  #--------------------------------------------------------------------------
  # * Posição do evento
  #--------------------------------------------------------------------------
  def command_202
    return true if $game_temp.in_battle
    character = get_character(@parameters[0])
    return true unless character
    # Se o método de endereçamento for por apontamento
    if @parameters[1] == 0
      # Definir a posição do herói
      character.moveto(@parameters[2], @parameters[3])
    # Se o método de endereçamento for por variáveis
    elsif @parameters[1] == 1
      # Definir a posição do herói
      character.moveto($game_variables[@parameters[2]], $game_variables[@parameters[3]])
    # Se o método de endereçamento for por troca com outro evento
    else
      old_x = character.x
      old_y = character.y
      character2 = get_character(@parameters[2])
      if character2
        character.moveto(character2.x, character2.y)
        character2.moveto(old_x, old_y)
      end
    end
    case @parameters[4]
    when 8  # Acima
      character.turn_up
    when 6  # Direita
      character.turn_right
    when 2  # Abaixo
      character.turn_down
    when 4  # Esquerda
      character.turn_left
    end
    # Forçar atualização para tornar igual as coordenadas do sprite do evento com às da nova posição
    $game_temp.need_update = true
    return true
  end
end

#==============================================================================
# ** Window_Item
#==============================================================================
class Window_Item < Window_Selectable
  #--------------------------------------------------------------------------
  # * Atualização do texto de ajuda
  #--------------------------------------------------------------------------
  def update_help
    if $scene.is_a?(Scene_Item) and $scene.message
      @help_window.set_text($scene.message)
    else
      @help_window.set_text(!self.item ? '' : self.item.description)
    end
  end
end

#==============================================================================
# ** Window_Skill
#==============================================================================
class Window_Skill < Window_Selectable
  #--------------------------------------------------------------------------
  # * Atualização do texto de ajuda
  #--------------------------------------------------------------------------
  def update_help
    if $scene.is_a?(Scene_Skill) and $scene.message
      @help_window.set_text($scene.message)
    else
      @help_window.set_text(!self.skill ? '' : self.skill.description)
    end
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Title
  #--------------------------------------------------------------------------
  alias diamond_abs_main main
  #--------------------------------------------------------------------------
  # * Processamento principal
  #--------------------------------------------------------------------------
  def main
    $game_range = []
    $game_drop = []
    diamond_abs_main
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  alias diamond_abs_update update
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :hotbar_sprite            # atalhos
  #--------------------------------------------------------------------------
  # * Processamento principal
  #--------------------------------------------------------------------------
  def main
    @spriteset = Spriteset_Map.new
    @message_window = Window_Message.new
    create_windows
    # Executar transições
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar tela de jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      update
      # Abortar loop se a tela foi alterada
      break if $scene != self
    end
    # Preparar para transição
    Graphics.freeze
    @spriteset.dispose
    @message_window.dispose
    dispose
    if $scene.is_a?(Scene_Title)
      Graphics.transition
      Graphics.freeze
    end
  end
  #--------------------------------------------------------------------------
  # * Criação de todas as janelas
  #--------------------------------------------------------------------------
  def create_windows
    @hud_sprite = Sprite_HUD.new
    @hotbar_sprite = Sprite_Hotbar.new
  end
  #--------------------------------------------------------------------------
  # * Exibição
  #--------------------------------------------------------------------------
  def dispose
    @hud_sprite.dispose
    @hotbar_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    diamond_abs_update
    @hud_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Teletransporte
  #--------------------------------------------------------------------------
  def transfer_player
    $game_temp.player_transferring = false
    if $game_map.map_id != $game_temp.player_new_map_id
      $game_map.setup($game_temp.player_new_map_id)
      $game_range.clear
      $game_drop.clear
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    # Definir a direção
    case $game_temp.player_new_direction
    when 2  # Abaixo
      $game_player.turn_down
    when 4  # Esquerda
      $game_player.turn_left
    when 6  # Direita
      $game_player.turn_right
    when 8  # Acima
      $game_player.turn_up
    end
    # Alinhar a posição do jogador
    $game_player.straighten
    # Atualizar mapa (executar eventos de processo paralelo)
    $game_map.update
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition(20)
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end
end

#==============================================================================
# ** Scene_Item
#==============================================================================
class Scene_Item
  #--------------------------------------------------------------------------
  alias diamond_abs_update update
  alias diamond_abs_update_item update_item
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :message                  # mensagem
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    if @delay
      if @delay > 0
        @delay -= 1
      else
        @message = nil
        @delay = nil
      end
    end
    diamond_abs_update
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame (Quando a janela de itens estiver ativa)
  #--------------------------------------------------------------------------
  def update_item
    if @item_window.item and @item_window.item.is_a?(RPG::Item) and $game_party.item_can_use?(@item_window.item.id)
      for key in HOTKEYS
        next unless Input.trigger?(key)
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        $game_party.actors[0].hotkeys[key] = -@item_window.item.id
        @message = MEMORIZED_TEXT
        @delay = 40
      end
    end
    diamond_abs_update_item
  end
end

#==============================================================================
# ** Scene_Skill
#==============================================================================
class Scene_Skill
  #--------------------------------------------------------------------------
  alias diamond_abs_update update
  alias diamond_abs_update_skill update_skill
  #--------------------------------------------------------------------------
  # * Variáveis públicas
  #--------------------------------------------------------------------------
  attr_reader   :message                  # mensagem
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def update
    if @delay
      if @delay > 0
        @delay -= 1
      else
        @message = nil
        @delay = nil
      end
    end
    diamond_abs_update
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame (Quando a janela de habilidades estiver ativa)
  #--------------------------------------------------------------------------
  def update_skill
    if @skill_window.skill
      for key in HOTKEYS
        next unless Input.trigger?(key)
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        @actor.hotkeys[key] = @skill_window.skill.id
        @message = MEMORIZED_TEXT
        @delay = 40
      end
    end
    diamond_abs_update_skill
  end
end

#==============================================================================
# ** Scene_Load
#==============================================================================
class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  alias diamond_abs_read_save_data read_save_data
  #--------------------------------------------------------------------------
  # * Ler dados do arquivo
  #     file : arquivo que será lido (aberto)
  #--------------------------------------------------------------------------
  def read_save_data(file)
    diamond_abs_read_save_data(file)
    $game_player.refresh
  end
end
