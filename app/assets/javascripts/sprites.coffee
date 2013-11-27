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

  window.spritesheet = new createjs.SpriteSheet({
			images: [window.loader.getResult "terrain"],
			frames: { width:32, height: 32 }
		});

  sprite1 = new createjs.Sprite(window.spritesheet)
  sprite1.gotoAndStop(1)

  window.stage.addChild sprite1

  createjs.Ticker.timingMode = createjs.Ticker.RAF
  createjs.Ticker.addEventListener("tick", tick)

tick = (event) ->
  window.stage.update()
