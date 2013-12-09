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
# on_cjs_init - a callback prior to createjs ticks on the stage
# on_cjs_tick - a callback for each createjs tick on the stage

window.init_graphics = () ->
  window.stage = new createjs.Stage "displayCanvas"
  stage = window.stage

  images = []
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

  Humanoid.images_loaded()
  Terrain.init_with_stage(window.stage)

  window.on_cjs_init() if window.on_cjs_init

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  createjs.Ticker.addEventListener("tick", tick)

tick = (event) ->
  if window.on_cjs_tick
    window.on_cjs_tick(event)
  window.stage.update(event)
