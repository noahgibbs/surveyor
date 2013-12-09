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
# Variables for terrains, see tilesheets.js.coffee
# sprite_sheet_params - a dictionary of Objects specifying createjs spritesheet objects by name
# on_cjs_init - a callback prior to createjs ticks on the stage
# on_cjs_tick - a callback for each createjs tick on the stage

window.init_graphics = () ->
  window.stage = new createjs.Stage "displayCanvas"
  stage = window.stage

  images = ["./terrain.png"]
  images = images.concat Terrain.images_to_load()
  images = images.concat Humanoid.images_to_load()

  manifest = []
  for image in images
    manifest.push src: image, id: image

  loader = new createjs.LoadQueue(false)
  loader.addEventListener "complete", handleSpritesLoaded
  loader.loadManifest manifest
  window.loader = loader

handleSpritesLoaded = () ->
  # Is this needed?
  $("#loader")[0].className = ""

  for own sheet_name, sheet of window.sprite_sheet_params
    preloaded_imgs = (window.loader.getResult(image) for image in sheet.images)
    sheet.sprite_sheet = new createjs.SpriteSheet
      frames: sheet.frames, images: preloaded_imgs, animations: sheet.animations

  Humanoid.images_loaded()
  Terrain.images_loaded()

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
