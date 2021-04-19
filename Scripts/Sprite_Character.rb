#==============================================================================
# Sprite_Character
#------------------------------------------------------------------------------
# Esta é o script que exibe os sprites dos Heróis. Levando em consideração
# a classe Game_Character fazendo correções quando necessário.
#==============================================================================

class Sprite_Character < RPG::Sprite
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_accessor :character                # Herói
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     viewport  : ponto de vista
  #     character : Herói
  #--------------------------------------------------------------------------
  
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    update
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Caso o ID de Tile, o nome do arquivo, ou a cor são diferentes da atual
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue
      # Lembrar ao ID de Tile, o nome do arquivo e a cor
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      # Caso o valor do ID de Tile seja válida
      if @tile_id >= 384
        self.bitmap = RPG::Cache.tile($game_map.tileset_name,
          @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16
        self.oy = 32
      # Caso o valor do ID de Tile seja inválido
      else
        self.bitmap = RPG::Cache.character(@character.character_name,
          @character.character_hue)
        @cw = bitmap.width / 4
        @ch = bitmap.height / 4
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
    # Definir a situação como visível
    self.visible = (not @character.transparent)
    # Se o gráfico for de um Herói
    if @tile_id == 0
      # Definir uma transferência regular
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    # Definir as coordenadas do Sprite
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    # Definir o nível de opacidade, a sinteticidade e a profundidade do Gramado
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    # Então é feita a animação
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end
