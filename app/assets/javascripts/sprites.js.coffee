# Variables this library adds to window:
#
# init_graphics - a callback to set up createjs stuff
# stage - a createjs stage
# loader - a createjs image preload queue
# terrain_tilesheet - a tilesheet for the terrain layer
#
# Variables expected in window, often optional:
#
# humanoids - see humanoids.js.coffee
# terrain_config - a dictionary with entries tile_width, tile_height, width, height
# terrain_tilesets - a list of tilesets for terrains
# terrain_layers - a list of layers of terrain data
# sprite_sheet_params - a dictionary of Objects specifying createjs spritesheet objects by name
# on_cjs_init - a callback prior to createjs ticks on the stage
# on_cjs_tick - a callback for each createjs tick on the stage

images_to_preload = []

window.init_graphics = () ->
  window.stage = new createjs.Stage "displayCanvas"
  stage = window.stage

  add_image_to_preload("./terrain.png")
  add_image_to_preload(tileset.image) for tileset in window.terrain_tilesets
  add_image_to_preload(image) for image in Humanoid.images_to_load()

  manifest = []
  for image in images_to_preload
    manifest.push src: image, id: image

  loader = new createjs.LoadQueue(false)
  loader.addEventListener "complete", handleSpritesLoaded
  loader.loadManifest manifest
  window.loader = loader

add_image_to_preload = (image_url) ->
  images_to_preload.push image_url if image_url?

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

handleSpritesLoaded = () ->
  # Is this needed?
  $("#loader")[0].className = ""

  for own sheet_name, sheet of window.sprite_sheet_params
    preloaded_imgs = (window.loader.getResult(image) for image in sheet.images)
    sheet.sprite_sheet = new createjs.SpriteSheet
      frames: sheet.frames, images: preloaded_imgs, animations: sheet.animations

  Humanoid.images_loaded()

  config = window.terrain_config
  tilesheet = new Tilesheet(config.width, config.height, config.tile_width, config.tile_height,
                            window.sprite_sheet_params["terrain_spritesheet"].sprite_sheet)
  window.stage.addChild(tilesheet.container)

  window.terrain_tilesheet = tilesheet

  window.on_cjs_init() if window.on_cjs_init

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  createjs.Ticker.addEventListener("tick", tick)

tick = (event) ->
  if window.on_cjs_tick
    window.on_cjs_tick(event)
  window.stage.update(event)
