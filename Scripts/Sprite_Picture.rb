#==============================================================================
# Sprite_Picture
#------------------------------------------------------------------------------
# Este Sprite exibe uma Figura. Levando em consideração a classe Game_Character 
# fazendo correções quando necessário.
#==============================================================================

class Sprite_Picture < Sprite
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     viewport : ponto de vista
  #     picture  : Figura
  #--------------------------------------------------------------------------
  
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    update
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
    # Se o nome de arquivo da imagem é diferente do atual
    if @picture_name != @picture.name
      # Lembrar nome para instâncias de variável
      @picture_name = @picture.name
      # Se o nome da imagem não estiver vazio...
      if @picture_name != ""
        # Selecionar o gráfico da imagem
        self.bitmap = RPG::Cache.picture(@picture_name)
      end
    end
    # Se o nome da imagem estiver vazio...
    if @picture_name == ""
      # Definir o Sprite como invisível
      self.visible = false
      return
    end
    # Definir o Sprite como visível
    self.visible = true
    # Definir o ponot de início de transferência
    if @picture.origin == 0
      self.ox = 0
      self.oy = 0
    else
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
    end
    # Definir as coordenadas do Sprite
    self.x = @picture.x
    self.y = @picture.y
    self.z = @picture.number
    # Definir o grau de magnitude, o nível de opacidade e a sinteticidade
    self.zoom_x = @picture.zoom_x / 100.0
    self.zoom_y = @picture.zoom_y / 100.0
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    # Definir a angulação e a cor
    self.angle = @picture.angle
    self.tone = @picture.tone
  end
end
