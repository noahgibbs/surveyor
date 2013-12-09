# Variables expected in window, often optional:
#
# terrain_config - a dictionary with entries tile_width, tile_height, width, height
# terrain_tilesets - a list of tilesets for terrains
# terrain_layers - a list of layers of terrain data

class window.Terrain

class window.TerrainTileset

class window.TerrainLayer

window.Terrain.images_to_load = () ->
  images = tileset.image for tileset in window.terrain_tilesets

# Hook to indicate images have been loaded
window.Terrain.images_loaded = () ->

class window.Tilesheet
  constructor: (@w, @h, @tile_w, @tile_h, @spritesheet) ->
    @container = new createjs.Container()
    @sprites = []

    for h in [0..(@h-1)]
      @sprites[h] = []
      for w in [0..(@w-1)]
        @sprites[h][w] = new createjs.Sprite(@spritesheet)
        @sprites[h][w].setTransform(w * @tile_w, h * @tile_h)
        @sprites[h][w].gotoAndStop(0)
        @container.addChild @sprites[h][w]

  set_sprites: (data) ->
    for row, i in data
      for terrain_val, j in row
        @sprites[i][j].gotoAndStop terrain_val
