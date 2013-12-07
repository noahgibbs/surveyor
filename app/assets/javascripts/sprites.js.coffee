# Variables added to window:
#
# init_graphics - a callback to set up createjs stuff
# stage - a createjs stage
# loader - a createjs image preload queue
# terrain_tilesheet - a tilesheet for the terrain layer
#
# Variables expected in window, often optional:
#
# humanoid_animations - a list of Humanoid objects specifying person, creature or equipment humanoid animations
# sprite_sheet_params - a list of Objects specifying createjs spritesheet objects
# on_tick - a callback for each createjs tick on the stage

window.init_graphics = () ->
  window.stage = new createjs.Stage "displayCanvas"
  stage = window.stage

  for humanoid in window.humanoid_animations
    window.sprite_sheet_params.push humanoid.as_sprite_sheet()

  manifest = []
  for sheet in window.sprite_sheet_params
    for image in sheet.images
      manifest.push src: image, id: image

  loader = new createjs.LoadQueue(false)
  loader.addEventListener "complete", handleSpritesLoaded
  loader.loadManifest manifest
  window.loader = loader

class window.Humanoid
  constructor: (@name, @options) ->
    @options = {} unless @options?
    @direction = @options.direction || "right"
    @action = @options.action || "stand"
    @tile_x = @options.x || 1
    @tile_y = @options.y || 1

  as_sprite_sheet: () ->
    name: @name,
    images: [
      "/sprites/#{@name}_walkcycle.png",  # 0-35
      "/sprites/#{@name}_hurt.png",       # 36-41
      "/sprites/#{@name}_slash.png",      # 42-65
      "/sprites/#{@name}_spellcast.png"   # 66-93
    ],
    frames: { width: 64, height: 64 },
    animations:
      stand_up: 0
      walk_up: [1, 8]
      stand_left: 9
      walk_left: [10, 17]
      stand_down: 18
      walk_down: [19, 26]
      stand_right: 27
      walk_right: [28, 35]
      hurt: [36,41,"hurt",0.25]
      slash_up: [42, 47]
      slash_left: [48, 53]
      slash_down: [54, 59]
      slash_right: [60, 65]
      spellcast_up: [66, 72]
      spellcast_left: [73, 79]
      spellcast_down: [80, 86]
      spellcast_right: [87, 93]

  init: () ->

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

  for sheet in window.sprite_sheet_params
    preloaded_imgs = (window.loader.getResult(image) for image in sheet.images)
    sheet.sprite_sheet = new createjs.SpriteSheet
      frames: sheet.frames, images: preloaded_imgs, animations: sheet.animations

  tilesheet = new Tilesheet(55, 42, 32, 32, window.sprite_sheet_params[0].sprite_sheet)
  window.stage.addChild(tilesheet.container)

  window.terrain_tilesheet = tilesheet

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  createjs.Ticker.addEventListener("tick", tick)

tick = (event) ->
  if window.on_tick
    window.on_tick(event)
  window.stage.update()
