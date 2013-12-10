# Variables this library adds to window (deprecated):
#
# terrain_tilesheet - a tilesheet for the terrain layer

# Variables expected in window, often optional:
#
# terrain_config - a dictionary with entries tile_width, tile_height, width, height
# terrain_tilesets - a list of tilesets for terrains
# terrain_layers - a list of layers of terrain data

terrains = []

class window.Terrain
  constructor: (@w, @h, @tw, @th, @tilesets, @layers) ->
    terrains.push this

    @w = 40 if @w > 40
    @h = 40 if @h > 40

    # Tiled uses the value "0" to mean "no terrain"
    @tilesets.unshift firstgid: 0, image: "/tiles/empty32.png", image_width: 32, image_height: 32

    @container = new createjs.Container

    # CreateJS allows specifying sprites in a spritesheet only based on its own calculated offsets,
    # unless we manually specify every frame for every image.  So instead, we'll calculate how many
    # sprites each spritesheet contains.  Basically, we track what offset CreateJS will happen to
    # be using in the spritesheet at the start of each tileset image.
    #
    # In many cases, this will be a constant offset from firstgid.  But we can't bet on that, and
    # we don't want weird bugs if anybody "messes it up".
    #
    offset = 0
    for tileset in @tilesets
      tileset.cjs_frame_offset = offset
      ts_size = parseInt(tileset.image_width / @tw) * parseInt(tileset.image_height / @th)
      offset += ts_size

  gid_to_tileset_and_id: (gid) ->
    for tileset, offset in @tilesets
      if gid >= tileset.firstgid && (!@tilesets[offset + 1]? || gid < @tilesets[offset + 1].firstgid)
        return [tileset, gid - tileset.firstgid]
    alert "Can't map GID #{gid} to tileset and ID!"
    false

  images_to_load: () ->
    images = (tileset.image for tileset in @tilesets)

  init_with_stage: (@stage) ->
    preloads = (window.loader.getResult(tileset.image) for tileset in @tilesets)
    @sprite_sheet = new createjs.SpriteSheet frames: { width: @tw, height: @th }, images: preloads

    for layer in @layers
      continue unless layer.visible

      sprites = []
      layer.container = new createjs.Container
      @container.addChild layer.container

      for h in [0..(@h-1)]
        sprites[h] = []
        for w in [0..(@w-1)]
          unless layer.data[h][w] is 0
            sprites[h][w] = new createjs.Sprite(@sprite_sheet)
            sprites[h][w].setTransform(w * @tw, h * @th)
            [tileset, id] = this.gid_to_tileset_and_id layer.data[h][w]
            console.debug("Can't resolve", layer.data[h][w], layer.name, h, w) unless tileset?
            sprites[h][w].gotoAndStop(tileset.cjs_frame_offset + id)
            layer.container.addChild sprites[h][w]

    @stage.addChild(@container)

window.Terrain.images_to_load = () ->
  images = []
  images = images.concat(terrain.images_to_load()) for terrain in terrains
  images

window.Terrain.init_with_stage = (stage) ->
  terrain.init_with_stage(stage) for terrain in terrains
