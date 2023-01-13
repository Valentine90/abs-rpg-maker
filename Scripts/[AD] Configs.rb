#==============================================================================
# ** Configs
#------------------------------------------------------------------------------
# Este script contém as configurações do sistema de batalha.
#------------------------------------------------------------------------------
# Autor: Valentine
# Versão: 2.0
# Última atualização: 13/01/2023
# Wiki: https://github.com/Valentine90/abs-rpg-maker/wiki
#==============================================================================

module Configs
  # Tecla utilizada para o herói atacar
  ATTACK_KEY = Input::KEYS[:letter_s]
  
  # Tecla utilizada para o herói se defender
  DEFEND_KEY = Input::KEYS[:letter_d]
  
  # Tecla utilizada para pegar item do chão
  GET_DROP_KEY = Input::C
  
  # Teclas de atalho utilizadas para lançar itens e habilidades
  HOTKEYS = [
    Input::KEYS[:num_1],
    Input::KEYS[:num_2],
    Input::KEYS[:num_3],
    Input::KEYS[:num_4],
    Input::KEYS[:num_5],
    Input::KEYS[:num_6],
    Input::KEYS[:num_7],
    Input::KEYS[:num_8],
    Input::KEYS[:num_9]
  ]
  
  # Intervalo (em frames) entre os ataques do herói
  ATTACK_TIME = 30
  
  # Intervalo (em segundos) entre a morte e o renascimento dos
  #inimigos
  ENEMY_RESPAWN_TIME = 5
  
  # Tempo (em segundos) para o item desaparecer do chão
  DROP_DESPAWN_TIME = 60
  
  # Tempo (em segundos) para recuperar o HP e o SP do herói
  RECOVER_TIME = 5
  
  # Quantidade de HP a ser recuperado
  # Fórmula: (AGI / 100) * RECOVER_HP
  RECOVER_HP = 20
  
  # Quantidade de SP a ser recuperado
  # Fórmula: (AGI / 100) * RECOVER_SP
  RECOVER_SP = 20
  
  # ID da animação utilizada ao subir de nível
  LEVEL_UP_ANIMATION_ID = 33 # 0 = nenhuma
  
  # Máximo de itens caídos no chão por mapa
  MAX_MAP_DROPS = 15
  
  # Ícone do ouro
  GOLD_ICON = '032-Item01'
  
  # Armas de longo alcance
  RANGE_WEAPONS = {}
  # RANGE_WEAPONS[ID da arma]
  RANGE_WEAPONS[17] = {
    :projectile_name  => 'Arrow', # Gráfico
    :item_id          => 30,      # ID do item
    :animation_id     => 4,       # ID da animação
    :speed            => 4,       # Velocidade
    :range            => 15,      # Alcance
    :animation        => false,   # Animação (opcional)
    :animation_suffix => '_bow'   # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[18] = {
    :projectile_name  => 'Arrow', # Gráfico
    :item_id          => 30,      # ID do item
    :animation_id     => 4,       # ID da animação
    :speed            => 4,       # Velocidade
    :range            => 15,      # Alcance
    :animation        => false,   # Animação (opcional)
    :animation_suffix => '_bow'   # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[19] = {
    :projectile_name  => 'Arrow', # Gráfico
    :item_id          => 30,      # ID do item
    :animation_id     => 4,       # ID da animação
    :speed            => 4,       # Velocidade
    :range            => 15,      # Alcance
    :animation        => false,   # Animação (opcional)
    :animation_suffix => '_bow'   # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[20] = {
    :projectile_name  => 'Arrow', # Gráfico
    :item_id          => 30,      # ID do item
    :animation_id     => 4,       # ID da animação
    :speed            => 4,       # Velocidade
    :range            => 15,      # Alcance
    :animation        => false,   # Animação (opcional)
    :animation_suffix => '_bow'   # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[21] = {
    :projectile_name  => 'Bullet', # Gráfico
    :item_id          => 31,       # ID do item
    :animation_id     => 4,        # ID da animação
    :speed            => 4,        # Velocidade
    :range            => 15,       # Alcance
    :animation        => false,    # Animação (opcional)
    :animation_suffix => '_gun'    # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[22] = {
    :projectile_name  => 'Bullet', # Gráfico
    :item_id          => 31,       # ID do item
    :animation_id     => 4,        # ID da animação
    :speed            => 4,        # Velocidade
    :range            => 15,       # Alcance
    :animation        => false,    # Animação (opcional)
    :animation_suffix => '_gun'    # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[23] = {
    :projectile_name  => 'Bullet', # Gráfico
    :item_id          => 31,       # ID do item
    :animation_id     => 4,        # ID da animação
    :speed            => 4,        # Velocidade
    :range            => 15,       # Alcance
    :animation        => false,    # Animação (opcional)
    :animation_suffix => '_gun'    # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[24] = {
    :projectile_name  => 'Bullet', # Gráfico
    :item_id          => 31,       # ID do item
    :animation_id     => 4,        # ID da animação
    :speed            => 4,        # Velocidade
    :range            => 15,       # Alcance
    :animation        => false,    # Animação (opcional)
    :animation_suffix => '_gun'    # Sufixo da animação (opcional)
  }
  RANGE_WEAPONS[33] = {
    :projectile_name  => 'Bullet', # Gráfico
    :item_id          => 31,       # ID do item
    :animation_id     => 4,        # ID da animação
    :speed            => 4,        # Velocidade
    :range            => 15,       # Alcance
    :animation        => false,    # Animação (opcional)
    :animation_suffix => '_gun'    # Sufixo da animação (opcional)
  }
  
  # Habilidades de longo alcance
  RANGE_SKILLS = {}
  # RANGE_SKILLS[ID da habilidade]
  RANGE_SKILLS[57] = {
    :projectile_name  => 'Fire02', # Gráfico
    :speed            => 4,        # Velocidade
    :range            => 15,       # Alcance
    :animation        => true,     # Animação (opcional)
    :animation_suffix => '_cast'   # Sufixo da animação (opcional)
  }
  
  # Explosivos de longo alcance
  RANGE_EXPLOSIVES = {}
  # RANGE_EXPLOSIVES[ID da habilidade]
  RANGE_EXPLOSIVES[7] = {
    :projectile_name  => 'ArrowExplode', # Gráfico
    :speed            => 4,              # Velocidade
    :range            => 15,             # Alcance
    :explosion_range  => 3,              # Alcance da explosão
    :animation        => false,          # Animação (opcional)
    :animation_suffix => '_cast'         # Sufixo da animação (opcional)
  }
  
  # Animação dos ataques corpo a corpo com armas
  MELEE_ANIMATIONS = {}
  # MELEE_ANIMATIONS[ID da arma] = sufixo da animação
  MELEE_ANIMATIONS[1] = '_melee'
  MELEE_ANIMATIONS[2] = '_melee'
  MELEE_ANIMATIONS[3] = '_melee'
  MELEE_ANIMATIONS[4] = '_melee'
  
  # Animação das habilidades
  SKILL_ANIMATIONS = {}
  # SKILL_ANIMATIONS[ID da habilidade] = sufixo da animação
  SKILL_ANIMATIONS[1] = '_cast'
  
  # Animação dos escudos
  DEFEND_ANIMATIONS = {}
  # DEFEND_ANIMATIONS[ID do escudo] = sufixo da animação
  DEFEND_ANIMATIONS[1] = '_defend'
  DEFEND_ANIMATIONS[2] = '_defend'
  DEFEND_ANIMATIONS[3] = '_defend'
  DEFEND_ANIMATIONS[4] = '_defend'
  
  # Tempo para as armas serem utilizadas novamente após o ataque
  COOLDOWN_WEAPONS = {}
  # COOLDOWN_WEAPONS[ID da arma] = tempo (em frames)
  COOLDOWN_WEAPONS[33] = 15
  
  # Tempo (em frames) para as habilidades serem utilizadas
  #novamente após serem lançadas
  COOLDOWN_SKILLS = 30
  
  # Habilidades em área
  AREA_SKILLS = {}
  # AREA_SKILLS[ID da habilidade] = área (em tiles)
  AREA_SKILLS[58] = 5
  
  # Tempo de duração dos status
  STATES_TIME = []
  # STATES[ID do status] = tempo (em segundos)
  STATES_TIME[1]  = 0 # 0 = até ser curado
  STATES_TIME[2]  = 10
  STATES_TIME[3]  = 10
  STATES_TIME[4]  = 10
  STATES_TIME[5]  = 10
  STATES_TIME[6]  = 10
  STATES_TIME[7]  = 10
  STATES_TIME[8]  = 10
  STATES_TIME[9]  = 10
  STATES_TIME[10] = 10
  STATES_TIME[11] = 10
  STATES_TIME[12] = 10
  
  # Texto mostrado ao memorizar um item ou uma habilidade no menu
  MEMORIZED_TEXT = 'Memorizou!'
  
  # Textos
  DAMAGE_TEXTS = {
    :critical => 'Crítico!',
    :miss     => 'Errou!',
    :level_up => 'Subiu nível!'
  }
  
  # Nome, negrito e tamanho da fonte do dano
  DAMAGE_FONT_NAME = 'Arial Black'
  DAMAGE_FONT_BOLD = true
  DAMAGE_FONT_SIZE = 18
  
  # Cor dos textos
  DAMAGE_COLORS = {
    :critical => Color.new(255, 255, 255), # Crítico
    :damage   => Color.new(255, 255, 255), # Dano
    :heal     => Color.new(176, 255, 144), # Cura
    :miss     => Color.new(255, 255, 255), # Errou
    :exp      => Color.new(255, 255, 0),   # Experiência
    :level_up => Color.new(255, 255, 255)  # Subiu nível
  }
end
