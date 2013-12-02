window.initMap = () ->
  window.stage = new createjs.Stage "displayCanvas"
  stage = window.stage

  manifest = [
    { src: "./terrain.png", id:"terrain"}
  ]

  loader = new createjs.LoadQueue(false)
  loader.addEventListener "complete", handleTerrainLoaded
  loader.loadManifest manifest
  window.loader = loader

handleTerrainLoaded = () ->
  terrainLoaded = true

  $("#loader")[0].className = ""

  window.terrain_spritesheet = new createjs.SpriteSheet({
			images: [window.loader.getResult "terrain"],
			frames: { width:32, height: 32 }
		});

  # Empty array-of-arrays, 55w by 42h
  sprites = []

  for h in [0..41]
    sprites[h] = []
    for w in [0..55]
      sprites[h][w] = new createjs.Sprite(window.terrain_spritesheet)
      sprites[h][w].setTransform(w * 32.0, h * 32.0)
      sprites[h][w].gotoAndStop(0)
      window.stage.addChild sprites[h][w]

  window.terrain_sprites = sprites

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  createjs.Ticker.addEventListener("tick", tick)

tick = (event) ->
  if window.on_tick
    window.on_tick(event)
  window.stage.update()

window.setSprites = (data) ->
  i = 0
  while i < data.length
    j = 0
    while j < data[i].length
      window.terrain_sprites[i][j].gotoAndStop(data[i][j])
      j++
    i++
