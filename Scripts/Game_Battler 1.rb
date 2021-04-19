#==============================================================================
# Game_Battler (Parte 1)
#------------------------------------------------------------------------------
# Esta classe considera os jogadores da batalha.
# Esta classe identifica os Aliados ou Heróis como (Game_Actor) e
# os Inimigos como (Game_Enemy).
#==============================================================================

class Game_Battler
 
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
 
  attr_reader   :battler_name             # Nome do Battler
  attr_reader   :battler_hue              # Cor do Battler
  attr_reader   :hp                       # HP
  attr_reader   :sp                       # MP
  attr_reader   :states                   # Status
  attr_accessor :hidden                   # Flag de posição escondida
  attr_accessor :immortal                 # Flag de imortalidade
  attr_accessor :damage_pop               # Flag de exibição do dano
  attr_accessor :damage                   # Valor do dano
  attr_accessor :critical                 # Flag de dano crítico
  attr_accessor :animation_id             # ID da Animação
  attr_accessor :animation_hit            # Flag de Animação de Golpe
  attr_accessor :white_flash              # Flag de Flash branco
  attr_accessor :blink                    # Piscar
 
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
 
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @hp = 0
    @sp = 0
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    @hidden = false
    @immortal = false
    @damage_pop = false
    @damage = nil
    @critical = false
    @animation_id = 0
    @animation_hit = false
    @white_flash = false
    @blink = false
    @current_action = Game_BattleAction.new
  end
 
  #--------------------------------------------------------------------------
  # Definição do Máximo de HP (MaxHP)
  #--------------------------------------------------------------------------
 
  def maxhp
    n = [[base_maxhp + @maxhp_plus, 1].max, 999999].min
    for i in @states
      n *= $data_states[i].maxhp_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999999].min
    return n
  end
 
  #--------------------------------------------------------------------------
  # Definição do Máximo de MP (MaxMP)
  #--------------------------------------------------------------------------
 
  def maxsp
    n = [[base_maxsp + @maxsp_plus, 0].max, 9999].min
    for i in @states
      n *= $data_states[i].maxsp_rate / 100.0
    end
    n = [[Integer(n), 0].max, 9999].min
    return n
  end
 
  #--------------------------------------------------------------------------
  # Definição do Ataque
  #--------------------------------------------------------------------------
 
  def str
    n = [[base_str + @str_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].str_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
 
  #--------------------------------------------------------------------------
  # Definição da Defesa
  #--------------------------------------------------------------------------
 
  def dex
    n = [[base_dex + @dex_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].dex_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
 
  #--------------------------------------------------------------------------
  # Definição da Agilidade
  #--------------------------------------------------------------------------
 
  def agi
    n = [[base_agi + @agi_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].agi_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
 
  #--------------------------------------------------------------------------
  # Definição da Inteligência
  #--------------------------------------------------------------------------
 
  def int
    n = [[base_int + @int_plus, 1].max, 999].min
    for i in @states
      n *= $data_states[i].int_rate / 100.0
    end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
 
  #--------------------------------------------------------------------------
  # Opções do MaxHP
  #
  #     maxhp : novo MaxHP
  #--------------------------------------------------------------------------
 
  def maxhp=(maxhp)
    @maxhp_plus += maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -9999].max, 9999].min
    @hp = [@hp, self.maxhp].min
  end
 
  #--------------------------------------------------------------------------
  # Opções do MaxMP
  #
  #     maxsp : novo MaxMP
  #--------------------------------------------------------------------------
 
  def maxsp=(maxsp)
    @maxsp_plus += maxsp - self.maxsp
    @maxsp_plus = [[@maxsp_plus, -9999].max, 9999].min
    @sp = [@sp, self.maxsp].min
  end

  #--------------------------------------------------------------------------
  # Opções de Ataque
  #
  #     str : ataque
  #--------------------------------------------------------------------------
 
  def str=(str)
    @str_plus += str - self.str
    @str_plus = [[@str_plus, -999].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Opções de Defesa
  #
  #     dex : defesa
  #--------------------------------------------------------------------------
 
  def dex=(dex)
    @dex_plus += dex - self.dex
    @dex_plus = [[@dex_plus, -999].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Opções de Agilidade
  #
  #     agi : agilidade
  #--------------------------------------------------------------------------
 
  def agi=(agi)
    @agi_plus += agi - self.agi
    @agi_plus = [[@agi_plus, -999].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Opções de Inteligência
  #
  #     int : magia
  #--------------------------------------------------------------------------
 
  def int=(int)
    @int_plus += int - self.int
    @int_plus = [[@int_plus, -999].max, 999].min
  end
 
  #--------------------------------------------------------------------------
  # Cálculo da Força do Ataque
  #--------------------------------------------------------------------------
 
  def hit
    n = 100
    for i in @states
      n *= $data_states[i].hit_rate / 100.0
    end
    return Integer(n)
  end
 
  #--------------------------------------------------------------------------
  # Cálculo da Defesa (armadura)
  #--------------------------------------------------------------------------
 
  def atk
    n = base_atk
    for i in @states
      n *= $data_states[i].atk_rate / 100.0
    end
    return Integer(n)
  end
 
  #--------------------------------------------------------------------------
  # Cálculo da Defesa (força)
  #--------------------------------------------------------------------------
 
  def pdef
    n = base_pdef
    for i in @states
      n *= $data_states[i].pdef_rate / 100.0
    end
    return Integer(n)
  end
 
  #--------------------------------------------------------------------------
  # Cálculo da Defesa Mágica
  #--------------------------------------------------------------------------
 
  def mdef
    n = base_mdef
    for i in @states
      n *= $data_states[i].mdef_rate / 100.0
    end
    return Integer(n)
  end
 
  #--------------------------------------------------------------------------
  # Cálculo de Esquiva
  #--------------------------------------------------------------------------
 
  def eva
    n = base_eva
    for i in @states
      n += $data_states[i].eva
    end
    return n
  end
 
  #--------------------------------------------------------------------------
  # Mudar HP
  #
  #     hp : novo HP
  #--------------------------------------------------------------------------
  
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    # Não cancela nenhum status
    for i in 1...$data_states.size
      if $data_states[i].zero_hp
        if self.dead?
          add_state(i)
        else
          remove_state(i)
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Mudar MP
  #
  #     sp : novo MP
  #--------------------------------------------------------------------------
 
  def sp=(sp)
    @sp = [[sp, maxsp].min, 0].max
  end
  
  #--------------------------------------------------------------------------
  # Recuperação Total
  #--------------------------------------------------------------------------
 
  def recover_all
    @hp = maxhp
    @sp = maxsp
    for i in @states.clone
      remove_state(i)
    end
  end
 
  #--------------------------------------------------------------------------
  # Usar Ação determinada
  #--------------------------------------------------------------------------
 
  def current_action
    return @current_action
  end
 
  #--------------------------------------------------------------------------
  # Cálculo da Velocidade da Ação
  #--------------------------------------------------------------------------
 
  def make_action_speed
    @current_action.speed = agi + rand(10 + agi / 4)
  end
 
  #--------------------------------------------------------------------------
  # Definição de Morte
  #--------------------------------------------------------------------------
 
  def dead?
    # Se o HP chegar a 0 e se não for Imortal, não há mais batalha
    return (@hp == 0 and not @immortal)
  end
  #--------------------------------------------------------------------------
  # Existência
  #--------------------------------------------------------------------------
 
  def exist?
    # Se não está escondido o HP for maior que 0 ou Imortal, o Herói existe
    return (not @hidden and (@hp > 0 or @immortal))
  end
 
  #--------------------------------------------------------------------------
  # HP chegou a 0?
  #--------------------------------------------------------------------------
 
  def hp0?
    # Se não está escondido e o HP for igual a 0 
    return (not @hidden and @hp == 0)
  end
 
  #--------------------------------------------------------------------------
  # Se o Herói pode entrar em Batalha
  #--------------------------------------------------------------------------
 
  def inputable?
    # Se não está escondido a se tem uma restição menor ou igual a 1
    return (not @hidden and restriction <= 1)
  end

  #--------------------------------------------------------------------------
  # Pode se Mover
  #--------------------------------------------------------------------------

  def movable?
    # Se não está escondido a se tem uma restição menor que 4
    return (not @hidden and restriction < 4)
  end

  #--------------------------------------------------------------------------
  # Utilização da Defesa
  #--------------------------------------------------------------------------
  def guarding?
    return (@current_action.kind == 0 and @current_action.basic == 1)
  end
 
  #--------------------------------------------------------------------------
  # Utilização do Descanso
  #--------------------------------------------------------------------------

  def resting?
    return (@current_action.kind == 0 and @current_action.basic == 3)
  end
end
