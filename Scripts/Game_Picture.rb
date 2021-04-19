#==============================================================================
# Game_Picture
#------------------------------------------------------------------------------
# Esta é a classe que trata das imagens
# Esta classe pode ser chamada utilizando $game_picture
#==============================================================================

class Game_Picture
 
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
 
  attr_reader   :number                   # Número da Imagem
  attr_reader   :name                     # Nome do Arquivo
  attr_reader   :origin                   # Origem
  attr_reader   :x                        # Coordenada X
  attr_reader   :y                        # Coordenada Y
  attr_reader   :zoom_x                   # Magnitude da Coordenada X
  attr_reader   :zoom_y                   # Magnitude da Coordenada Y
  attr_reader   :opacity                  # Opacidade
  attr_reader   :blend_type               # Sinteticidade
  attr_reader   :tone                     # Tom
  attr_reader   :angle                    # Ângulo
 
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     number : Número da Imagem
  #--------------------------------------------------------------------------
 
  def initialize(number)
    @number = number
    @name = ""
    @origin = 0
    @x = 0.0
    @y = 0.0
    @zoom_x = 100.0
    @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end

  #--------------------------------------------------------------------------
  # Aparecimento da Imagem
  #
  #     name         : Nome do Arquivo
  #     origin       : Origem
  #     x            : Coordenada X
  #     y            : Coordenada Y
  #     zoom_x       : Magnitude da Coordenada X
  #     zoom_y       : Magnitude da Coordenada Y
  #     opacity      : Opacidade
  #     blend_type   : Sinteticidade
  #--------------------------------------------------------------------------

  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end
 
  #--------------------------------------------------------------------------
  # Movimento da Imagem
  #
  #     duration     : Duração
  #     origin       : Origem
  #     x            : Coordenada X
  #     y            : Coordenada Y
  #     zoom_x       : Magnitude da Coordenada X
  #     zoom_y       : Magnitude da Coordenada Y
  #     opacity      : Opacidade
  #     blend_type   : Sinteticidade
  #--------------------------------------------------------------------------
 
  def move(duration, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @duration = duration
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
  end
 
  #--------------------------------------------------------------------------
  # Configuração da Velocidade de Rotação
  #
  #     speed : velocidade da rotação
  #--------------------------------------------------------------------------
 
  def rotate(speed)
    @rotate_speed = speed
  end
 
  #--------------------------------------------------------------------------
  # Início da Alteração do Tom da Imagem
  #
  #     tone     : Tom
  #     duration : Duração da Alteração
  #--------------------------------------------------------------------------

  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
 
  #--------------------------------------------------------------------------
  # Eliminação da Imagem
  #
  #     name : Nome do Arquivo
  #--------------------------------------------------------------------------
 
  def erase
    @name = ""
  end
 
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
 
  def update
    if @duration >= 1
      d = @duration
      @x = (@x * (d - 1) + @target_x) / d
      @y = (@y * (d - 1) + @target_y) / d
      @zoom_x = (@zoom_x * (d - 1) + @target_zoom_x) / d
      @zoom_y = (@zoom_y * (d - 1) + @target_zoom_y) / d
      @opacity = (@opacity * (d - 1) + @target_opacity) / d
      @duration -= 1
    end
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @rotate_speed != 0
      @angle += @rotate_speed / 2.0
      while @angle < 0
        @angle += 360
      end
      @angle %= 360
    end
  end
end
