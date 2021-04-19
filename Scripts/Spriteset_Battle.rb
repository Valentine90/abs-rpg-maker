#==============================================================================
# Spriteset_Battle
#------------------------------------------------------------------------------
# Esta classe une os Sprites de Batalha na tela. Esta clase é usada juntamente
# com a classe Scene_Battle
#==============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :viewport1                # Viewport do inimigo
  attr_reader   :viewport2                # Viewport do herói
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    # Criação dos viewports
    @viewport1 = Viewport.new(0, 0, 640, 320)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport4 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 101
    @viewport3.z = 200
    @viewport4.z = 5000
    # Criação do sprite de Fundo de Batalha
    @battleback_sprite = Sprite.new(@viewport1)
    # Criação dos sprites dos Inimigos
    @enemy_sprites = []
    for enemy in $game_troop.enemies.reverse
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    end
    # Criação dos sprites dos heróis
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    # Criação do Clima
    @weather = RPG::Weather.new(@viewport1)
    # Criação das Imagens
    @picture_sprites = []
    for i in 51..100
      @picture_sprites.push(Sprite_Picture.new(@viewport3,
        $game_screen.pictures[i]))
    end
    # Criação do sprite do Temporizador
    @timer_sprite = Sprite_Timer.new
    # Atualização do frame
    update
  end
  
  #--------------------------------------------------------------------------
  # Exibição
  #--------------------------------------------------------------------------
  
  def dispose
    # Se o Fundo de Batalha existir, então exibir
    if @battleback_sprite.bitmap != nil
      @battleback_sprite.bitmap.dispose
    end
    # Exibição do Sprite do Fundo de Batalha
    @battleback_sprite.dispose
    # Exibição dos Sprites dos Inimigos e dos Heróis
    for sprite in @enemy_sprites + @actor_sprites
      sprite.dispose
    end
    # Exibir Clima
    @weather.dispose
    # Exibir Sprites de Imagens
    for sprite in @picture_sprites
      sprite.dispose
    end
    # Exibição do Temporizador
    @timer_sprite.dispose
    # Exibição dos Pontos de Vista
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    @viewport4.dispose
  end
  
  #--------------------------------------------------------------------------
  # Determinar se os Efeitos estão sendo Exibidos
  #--------------------------------------------------------------------------
  
  def effect?
    # Retornar como verdadeiro se 1 efeito estiver sendo exibido
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.effect?
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar o conteúdo dos Sprites dos Heróis 
    # (Corresponde à troca de Heróis)
    @actor_sprites[0].battler = $game_party.actors[0]
    @actor_sprites[1].battler = $game_party.actors[1]
    @actor_sprites[2].battler = $game_party.actors[2]
    @actor_sprites[3].battler = $game_party.actors[3]
    # Se o nome do arquivo do Fundo de Batalha for diferente do atual
    if @battleback_name != $game_temp.battleback_name
      @battleback_name = $game_temp.battleback_name
      if @battleback_sprite.bitmap != nil
        @battleback_sprite.bitmap.dispose
      end
      @battleback_sprite.bitmap = RPG::Cache.battleback(@battleback_name)
      @battleback_sprite.src_rect.set(0, 0, 640, 320)
    end
    # Atualizar Sprites dos Battlers
    for sprite in @enemy_sprites + @actor_sprites
      sprite.update
    end
    # Atualizar gráficos do Clima
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.update
    # Atualizar Sprites das Imagens
    for sprite in @picture_sprites
      sprite.update
    end
    # Atualizar o Sprite do Temporizador
    @timer_sprite.update
    # Definir cor da Tela e posição do tremor
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # Definir cor do Flash
    @viewport4.color = $game_screen.flash_color
    # Atualização dos Pontos de Vista
    @viewport1.update
    @viewport2.update
    @viewport4.update
  end
end
