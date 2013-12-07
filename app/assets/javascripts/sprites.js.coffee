# Variables this library adds to window:
#
# init_graphics - a callback to set up createjs stuff
# stage - a createjs stage
# loader - a createjs image preload queue
# terrain_tilesheet - a tilesheet for the terrain layer
#
# Variables expected in window, often optional:
#
# humanoids - a list of Humanoid objects specifying sprite-stacks with humanlike animations
# sprite_sheet_params - a dictionary of Objects specifying createjs spritesheet objects by name
# on_cjs_init - a callback prior to createjs ticks on the stage
# on_cjs_tick - a callback for each createjs tick on the stage

window.init_graphics = () ->
  window.stage = new createjs.Stage "displayCanvas"
  stage = window.stage

  manifest = []
  for own sheet_name, sheet of window.sprite_sheet_params
    for image in sheet.images
      manifest.push src: image, id: image

  loader = new createjs.LoadQueue(false)
  loader.addEventListener "complete", handleSpritesLoaded
  loader.loadManifest manifest
  window.loader = loader

add_humanoid_animation = (name) ->
  unless window.sprite_sheet_params[name]?
    window.sprite_sheet_params[name] =
      images: [
        "/sprites/#{name}_walkcycle.png",  # 0-35
        "/sprites/#{name}_hurt.png",       # 36-41
        "/sprites/#{name}_slash.png",      # 42-65
        "/sprites/#{name}_spellcast.png"   # 66-93
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

class window.Humanoid
  constructor: (@name, @options) ->
    @options = {} unless @options?
    @direction = @options.direction || "right"
    @action = @options.action || "stand"
    @x = @options.x || 1
    @y = @options.y || 1
    @animation_stack = @options.animation_stack || [@name]
    add_humanoid_animation(animation) for animation in @animation_stack

  init: (@stage) ->
    @container = new createjs.Container
    @stage.addChild @container

    @sprite_stack = []
    for anim in @animation_stack
      sprite = new createjs.Sprite window.sprite_sheet_params[anim].sprite_sheet
      @sprite_stack.push sprite
      @container.addChild sprite
    this.set_sprite_params()

  set_sprite_params: () ->
    @container.setTransform @x, @y
    for sprite in @sprite_stack
      sprite.framerate = 7
      sprite.gotoAndPlay "#{@action}_#{@direction}"

window.Humanoid.init_with_stage = (stage) ->
  for humanoid in window.humanoids
    humanoid.init(stage)

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

  tilesheet = new Tilesheet(55, 42, 32, 32, window.sprite_sheet_params["terrain_spritesheet"].sprite_sheet)
  window.stage.addChild(tilesheet.container)

  window.terrain_tilesheet = tilesheet

  window.on_cjs_init() if window.on_cjs_init

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  createjs.Ticker.addEventListener("tick", tick)

tick = (event) ->
  if window.on_cjs_tick
    window.on_cjs_tick(event)
  window.stage.update(event)
