# Variables expected in window, often optional:
#
# loader - the createjs image preloader object
# humanoids - a list of Humanoid objects specifying sprite-stacks with humanlike animations

humanoid_sprite_sheet_params = {}
humanoid_sprite_sheets = {}
add_humanoid_animation = (name) ->
  unless humanoid_sprite_sheet_params[name]
    humanoid_sprite_sheet_params[name] =
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
    @x = if @options.x? then @options.x else 1
    @y = if @options.y? then @options.y else 1
    @animation_stack = @options.animation_stack || [@name]
    add_humanoid_animation(animation) for animation in @animation_stack

  init: (@outer_container) ->
    @container = new createjs.Container
    @outer_container.addChild @container

    @sprite_stack = []
    for anim in @animation_stack
      sprite = new createjs.Sprite humanoid_sprite_sheets[anim]
      @sprite_stack.push sprite
      @container.addChild sprite
    this.set_sprite_params()

  set_sprite_params: () ->
    @container.setTransform @screen_x_for_terrain_x(@x), @screen_y_for_terrain_y(@y)
    for sprite in @sprite_stack
      sprite.framerate = 7
      sprite.gotoAndPlay "#{@action}_#{@direction}"

  # Humanoid sprites are 64x64.  Terrain sprites are 32x32.
  # Feet-points in a humanoid sprite are usually close to (32, 52).
  # We adjust the humanoid's (32,52) to the center of the terrain
  # sprite at (@x * 32 + 16, @y * 32 + 16).
  screen_x_for_terrain_x: (x) -> x * 32 + 16 - 32
  screen_y_for_terrain_y: (y) -> y * 32 + 16 - 52

  animate_move_to: (x, y, anim = "walk") ->
    delta_x = x - @x
    delta_y = y - @y

    if Math.abs(delta_y) > Math.abs(delta_x)
      anim_dir = if delta_y > 0 then "down" else "up"
    else
      anim_dir = if delta_x > 0 then "right" else "left"

    @direction = anim_dir
    @action = anim

  jump_to: (x, y) ->
    @x = x
    @y = y
    @set_sprite_params()

  move_to: (x, y, anim = "walk") ->
    distance = Math.sqrt( (@x - x) * (@x - x) + (@y - y) * (@y - y) )
    @animate_move_to(x, y, anim)  # Pick action and direction
    @set_sprite_params()  # Use new animation
    new_x = @screen_x_for_terrain_x(x)
    new_y = @screen_y_for_terrain_y(y)
    createjs.Tween.get(@container)
      .to({x: new_x, y: new_y}, distance * 800.0, createjs.Ease.linear)
      .call (tween) =>  # on complete, set new @x and @y
        @x = x
        @y = y
        @action = "stand"
        @set_sprite_params()

window.Humanoid.init_with_container = (cont) ->
  for humanoid in window.humanoids
    humanoid.init(cont)

# Get list of image URLs to preload
window.Humanoid.images_to_load = () ->
  images = []
  images = images.concat(params.images) for name, params of humanoid_sprite_sheet_params
  images

# Hook to indicate images have been loaded
window.Humanoid.images_loaded = () ->
  for own sheet_name, sheet of humanoid_sprite_sheet_params
    preloaded_imgs = (window.loader.getResult(image) for image in sheet.images)
    humanoid_sprite_sheets[sheet_name] = new createjs.SpriteSheet
      frames: sheet.frames, images: preloaded_imgs, animations: sheet.animations
