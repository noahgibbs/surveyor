window.initMap = () ->
  window.stage = new createjs.Stage "displayCanvas"
  stage = window.stage

  manifest = []
  for sheet in window.sprite_sheets
    for image in sheet.images
      manifest.push src: image, id: image

  loader = new createjs.LoadQueue(false)
  loader.addEventListener "complete", handleSpritesLoaded
  loader.loadManifest manifest
  window.loader = loader

class Tilesheet
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
    i = 0
    while i < data.length
      j = 0
      while j < data[i].length
        @sprites[i][j].gotoAndStop(data[i][j])
        j++
      i++

handleSpritesLoaded = () ->
  # Is this needed?
  $("#loader")[0].className = ""

  for sheet in window.sprite_sheets
    preloaded_imgs = []
    preloaded_imgs.push(window.loader.getResult image) for image in sheet.images
    window[sheet.name] = new createjs.SpriteSheet frames: sheet.frames, images: preloaded_imgs

  tilesheet = new Tilesheet(55, 42, 32, 32, window.terrain_spritesheet)

  window.terrain_tilesheet = tilesheet
  window.stage.addChild(tilesheet.container)

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  createjs.Ticker.addEventListener("tick", tick)

tick = (event) ->
  if window.on_tick
    window.on_tick(event)
  window.stage.update()
