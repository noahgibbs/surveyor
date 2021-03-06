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
  constructor: (@w, @h, @tw, @th, @vieww, @viewh, @tilesets, @layers) ->
    terrains.push this

    @scrollx = 0
    @scrolly = 0

    # Tiled uses the value "0" to mean "no terrain"
    @tilesets.unshift firstgid: 0, image: "/tiles/empty32.png", image_width: 32, image_height: 32

    @lower_internal_container = new createjs.Container
    @upper_internal_container = new createjs.Container

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

  init_with_containers: (@lower_external_container, @upper_external_container) ->
    preloads = (window.loader.getResult(tileset.image) for tileset in @tilesets)
    @sprite_sheet = new createjs.SpriteSheet frames: { width: @tw, height: @th }, images: preloads

    below_fringe = true
    for layer in @layers
      if layer.name == "Collision"
        @collision_grid = ((if square == 0 then false else true) for square in row for row in layer.data)
        continue

      # Skip invisible layers
      continue unless layer.visible

      # Fringe-and-later layers are drawn over top of humanoid sprites
      below_fringe = false if layer.name == "Fringe"

      sprites = []
      layer.container = new createjs.Container
      layer.container.alpha = layer.opacity
      if below_fringe
        @lower_internal_container.addChild layer.container
      else
        @upper_internal_container.addChild layer.container

      for h in [0..(Math.min(@h, @viewh)-1)]
        sprites[h] = []
        for w in [0..(Math.min(@w, @vieww)-1)]
          unless layer.data[h][w] is 0
            sprites[h][w] = new createjs.Sprite(@sprite_sheet)
            sprites[h][w].setTransform(w * @tw, h * @th)
            [tileset, id] = this.gid_to_tileset_and_id layer.data[h][w]
            console.debug("Can't resolve", layer.data[h][w], layer.name, h, w) unless tileset?
            sprites[h][w].gotoAndStop(tileset.cjs_frame_offset + id)
            layer.container.addChild sprites[h][w]

    @lower_external_container.addChild(@lower_internal_container)
    @upper_external_container.addChild(@upper_internal_container)

    unless @collision_grid?
      @collision_grid = (false for item in row for row in @layers[0].data)
      console.info @collision_grid

  is_spot_open: (x, y) -> @collision_grid[y][x]

  random_open_spot: () ->
    return [0,0] unless @collision_grid?

    for try_number in [0..20]
      x = window.Utils.int_random 0, @w - 1
      y = window.Utils.int_random 0, @h - 1
      return [x, y] unless @collision_grid[y][x]

    alert "Can't find an open spot!"
    return [0, 0]

window.Terrain.images_to_load = () ->
  images = []
  images = images.concat(terrain.images_to_load()) for terrain in terrains
  images

window.Terrain.init_with_containers = (lower_cont, upper_cont) ->
  terrain.init_with_containers(lower_cont, upper_cont) for terrain in terrains

window.Terrain.clear_terrains = () ->
  terrains = []
