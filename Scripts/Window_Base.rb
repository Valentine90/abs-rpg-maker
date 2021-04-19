#==============================================================================
# Window_Base
#------------------------------------------------------------------------------
# Esta classe é para todos as janelas do jogo
#==============================================================================

class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     x      : coordenada x da janela
  #     y      : coordenada y da janela
  #     width  : largura da janela
  #     height : altura da janela
  #--------------------------------------------------------------------------
  
  def initialize(x, y, width, height)
    super()
    @windowskin_name = $game_system.windowskin_name
    self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
  end
  
  #--------------------------------------------------------------------------
  # Exibição
  #--------------------------------------------------------------------------
  
  def dispose
    # Exibir se um bitmap for definido
    if self.contents != nil
      self.contents.dispose
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # Selcionar Cor do Texto
  #
  #     n : número da cor do texto (0-7)
  # (Se quiser alterar, utilize o mesmo padrão (R,G,B, o último é a Gama)
  #--------------------------------------------------------------------------
  
  def text_color(n)
    case n
    when 0
      return Color.new(255, 255, 255, 255)
    when 1
      return Color.new(128, 128, 255, 255)
    when 2
      return Color.new(255, 128, 128, 255)
    when 3
      return Color.new(128, 255, 128, 255)
    when 4
      return Color.new(128, 255, 255, 255)
    when 5
      return Color.new(255, 128, 255, 255)
    when 6
      return Color.new(255, 255, 128, 255)
    when 7
      return Color.new(192, 192, 192, 255)
    else
      normal_color
    end
  end
  
  #--------------------------------------------------------------------------
  # Definir cor normal do texto (neste caso branca)
  #--------------------------------------------------------------------------
  
  def normal_color
    return Color.new(255, 255, 255, 255)
  end
  
  #--------------------------------------------------------------------------
  # Desabilitar Cor do Texto
  #--------------------------------------------------------------------------
  
  def disabled_color
    return Color.new(255, 255, 255, 128)
  end
  
  #--------------------------------------------------------------------------
  # Definir Cor do Texto do Sistema
  #--------------------------------------------------------------------------
  
  def system_color
    return Color.new(192, 224, 255, 255)
  end
  
  #--------------------------------------------------------------------------
  # Definir Cor do Texto do Crítico (neste caso amarela)
  #--------------------------------------------------------------------------
  
  def crisis_color
    return Color.new(255, 255, 64, 255)
  end
  
  #--------------------------------------------------------------------------
  # Difinir Cor do Texto do Dano (neste caso vermelha)
  #--------------------------------------------------------------------------
  
  def knockout_color
    return Color.new(255, 64, 0)
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Resetar se uma Windowskin for alterada
    if $game_system.windowskin_name != @windowskin_name
      @windowskin_name = $game_system.windowskin_name
      self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    end
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Gráfico
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #--------------------------------------------------------------------------
  
  def draw_actor_graphic(actor, x, y)
    bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
    cw = bitmap.width / 4
    ch = bitmap.height / 4
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
 
  #--------------------------------------------------------------------------
  # Desenhar Nome
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 120, 32, actor.name)
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Classe
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #--------------------------------------------------------------------------
  
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 236, 32, actor.class_name)
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Nível
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #--------------------------------------------------------------------------
  
  def draw_actor_level(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, "Lv")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 32, y, 24, 32, actor.level.to_s, 2)
  end
  
  #--------------------------------------------------------------------------
  # Criar String de Status para Desenhar
  #
  #     actor       : Herói
  #     width       : Desenhar o comprimento
  #     need_normal : Quer seja, ou não [Normal], need= verdadeiro ou falso
  #--------------------------------------------------------------------------
  
  def make_battler_state_text(battler, width, need_normal)
    # Selecionar comrpimento dos Colchetes
    brackets_width = self.contents.text_size("[]").width
    # Criar um string de Status para texto
    text = ""
    for i in battler.states
      if $data_states[i].rating >= 1
        if text == ""
          text = $data_states[i].name
        else
          new_text = text + "/" + $data_states[i].name
          text_width = self.contents.text_size(new_text).width
          if text_width > width - brackets_width
            break
          end
          text = new_text
        end
      end
    end
    # Caso esteja vazio o string de texto, tornar isto Normal
    if text == ""
      if need_normal
        text = "[Normal]"
      end
    else
      # Anexar Colchetes
      text = "[" + text + "]"
    end
    # Retornar string de texto
    return text
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Status
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #     width : Desenhar o comprimento
  #--------------------------------------------------------------------------
  
  def draw_actor_state(actor, x, y, width = 120)
    text = make_battler_state_text(actor, width, true)
    self.contents.font.color = actor.hp == 0 ? knockout_color : normal_color
    self.contents.draw_text(x, y, width, 32, text)
  end
  
  #--------------------------------------------------------------------------
  # Desenhar EXP
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #--------------------------------------------------------------------------
  
  def draw_actor_exp(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 24, 32, "E")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 24, y, 84, 32, actor.exp_s, 2)
    self.contents.draw_text(x + 108, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 120, y, 84, 32, actor.next_exp_s)
  end
  
  #--------------------------------------------------------------------------
  # Desenhar HP
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #     width : Desenhar comprimento
  #--------------------------------------------------------------------------
  
  def draw_actor_hp(actor, x, y, width = 144)
    # Desenhar string de texto do HP
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.hp)
    # Calcular se há espaço para o HP Max
    if width - 32 >= 108
      hp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      hp_x = x + width - 48
      flag = false
    end
    # Desenhar HP
    self.contents.font.color = actor.hp == 0 ? knockout_color :
      actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
    self.contents.draw_text(hp_x, y, 48, 32, actor.hp.to_s, 2)
    # Desenhar HP Max
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(hp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(hp_x + 60, y, 48, 32, actor.maxhp.to_s)
    end
  end
  
  #--------------------------------------------------------------------------
  # Desenhar MP
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #     width : Desenhar comprimento
  #--------------------------------------------------------------------------
  
  def draw_actor_sp(actor, x, y, width = 144)
    # Desenhar o string de texto do MP
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.sp)
    # Calcular se há espaço para o MP Max
    if width - 32 >= 108
      sp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      sp_x = x + width - 48
      flag = false
    end
    # Desenhar MP
    self.contents.font.color = actor.sp == 0 ? knockout_color :
      actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
    self.contents.draw_text(sp_x, y, 48, 32, actor.sp.to_s, 2)
    # Desenhar MP Max
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(sp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(sp_x + 60, y, 48, 32, actor.maxsp.to_s)
    end
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Parâmetro
  #
  #     actor : Herói
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #     width : Desenhar comprimento
  #     type  : tipo de parâmetro (0-6)
  #--------------------------------------------------------------------------
  
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = $data_system.words.atk
      parameter_value = actor.atk
    when 1
      parameter_name = $data_system.words.pdef
      parameter_value = actor.pdef
    when 2
      parameter_name = $data_system.words.mdef
      parameter_value = actor.mdef
    when 3
      parameter_name = $data_system.words.str
      parameter_value = actor.str
    when 4
      parameter_name = $data_system.words.dex
      parameter_value = actor.dex
    when 5
      parameter_name = $data_system.words.agi
      parameter_value = actor.agi
    when 6
      parameter_name = $data_system.words.int
      parameter_value = actor.int
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, 32, parameter_value.to_s, 2)
  end
  
  #--------------------------------------------------------------------------
  # Desenhar Nome do Item
  #
  #     item  : Item
  #     x     : Desenhar a partir da coordenada x
  #     y     : Desenhar a partir da coordenada y
  #--------------------------------------------------------------------------
  
  def draw_item_name(item, x, y)
    if item == nil
      return
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 28, y, 212, 32, item.name)
  end
end
