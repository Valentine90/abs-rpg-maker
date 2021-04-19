#==============================================================================
# Sprite_Battler
#------------------------------------------------------------------------------
# Aqui é exibido o sprite que representa o Battler. Levando em consideração a
# classe Game_Character fazendo correções quando necessário.
#==============================================================================

class Sprite_Battler < RPG::Sprite
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_accessor :battler                  # Battler
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     viewport : ponto de vista
  #     battler  : Battler (Game_Battler)
  #--------------------------------------------------------------------------
  
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @battler_visible = false
  end
  
  #--------------------------------------------------------------------------
  # Disposição
  #--------------------------------------------------------------------------
  
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  
    end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Se battler for nulo, não será exibido nenhuma imagem
    if @battler == nil
      self.bitmap = nil
      loop_animation(nil)
      return
    end
    # Se o nome do arquivo ou a cor forem diferentes da atual
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      # Definir uma imagem
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = RPG::Cache.battler(@battler_name, @battler_hue)
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      # Modificar a cor para 0 quando estiver escondido ou morto
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
    end
    # Se o ID da animação for diferente da atual
    if @battler.damage == nil and
       @battler.state_animation_id != @state_animation_id
      @state_animation_id = @battler.state_animation_id
      loop_animation($data_animations[@state_animation_id])
    end
    # Se o Battler for visível
    if @battler.is_a?(Game_Actor) and @battler_visible
      # Diminuir um pouco a opacidade durante a fase principal
      if $game_temp.battle_main_phase
        self.opacity += 3 if self.opacity < 255
      else
        self.opacity -= 3 if self.opacity > 207
      end
    end
    # Cego
    if @battler.blink
      blink_on
    else
      blink_off
    end
    # Caso estaja invisível
    unless @battler_visible
      # Aqui o Comabatente aparece
      if not @battler.hidden and not @battler.dead? and
         (@battler.damage == nil or @battler.damage_pop)
        appear
        @battler_visible = true
      end
    end
    # Se estiver visível
    if @battler_visible
      # Aqui o battler escapa
      if @battler.hidden
        $game_system.se_play($data_system.escape_se)
        escape
        @battler_visible = false
      end
      # Flash branco
      if @battler.white_flash
        whiten
        @battler.white_flash = false
      end
      # Animação
      if @battler.animation_id != 0
        animation = $data_animations[@battler.animation_id]
        animation(animation, @battler.animation_hit)
        @battler.animation_id = 0
      end
      # Dano
      if @battler.damage_pop
        damage(@battler.damage, @battler.critical)
        @battler.damage = nil
        @battler.critical = false
        @battler.damage_pop = false
      end
      # Morte
      if @battler.damage == nil and @battler.dead?
        if @battler.is_a?(Game_Enemy)
          $game_system.se_play($data_system.enemy_collapse_se)
        else
          $game_system.se_play($data_system.actor_collapse_se)
        end
        collapse
        @battler_visible = false
      end
    end
    # Definir coordenadas do sprite
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
  end
end
