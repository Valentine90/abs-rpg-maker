#==============================================================================
# Spriteset_Map
#------------------------------------------------------------------------------
# Esta classe engloba todos os sprites da tela, Tilesets, Heróis, etc
# Esta classe está inserida na classe Scene_Map.
#==============================================================================

class Spriteset_Map
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #--------------------------------------------------------------------------
  
  def initialize
    # Criar pontos de vista
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    # Aqui é criado um tilemap que comporta o tileset e seus autotiles
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    # Aqui é criado um plano para o Panorama
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    # Aqui é criado outro plano, para a Névoa
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    # Aqui são criados os sprites dos Heróis
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    # Aqui é criado o Clima
    @weather = RPG::Weather.new(@viewport1)
    # Aqui são criados os sprites das Figuras
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_screen.pictures[i]))
    end
    # Aqui é criado o sprite do Temporizador
    @timer_sprite = Sprite_Timer.new
    # E aqui o frame é atualizado
    update
  end
  
  #--------------------------------------------------------------------------
  # Exibição
  #--------------------------------------------------------------------------
  
  def dispose
    # Disposição do Tilemap
    @tilemap.tileset.dispose
    for i in 0..6
      @tilemap.autotiles[i].dispose
    end
    @tilemap.dispose
    # Disposição do plano do Panorama
    @panorama.dispose
    # Disposição do plano da Névoa
    @fog.dispose
    # Disposição dos sprites dos Heróis
    for sprite in @character_sprites
      sprite.dispose
    end
    # Disposição do Clima
    @weather.dispose
    # Disposição dos sprites da Figuras
    for sprite in @picture_sprites
      sprite.dispose
    end
    # Disposição do Temporizador
    @timer_sprite.dispose
    # Disposição dos pontos de vista
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Se o Panorama for diferente do atual
    if @panorama_name != $game_map.panorama_name or
      @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    # Se a Névoa for diferente da atual
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    # Atualizar o Tilemap
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    # Atualizar o plano do Panorama
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    # Atualizar o plano da Névoa
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    # Atualizar os sprites dos Heróis
    for sprite in @character_sprites
      sprite.update
    end
    # Atualizar o Clima
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    # Atualiza os sprites das Figuras
    for sprite in @picture_sprites
      sprite.update
    end
    # Atualiza o sprite do Temporizador
    @timer_sprite.update
    # Definir cor e tom do Tremor
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # Definir cor do Flash
    @viewport3.color = $game_screen.flash_color
    # Atualizar os pontos de vista
    @viewport1.update
    @viewport3.update
  end
end
