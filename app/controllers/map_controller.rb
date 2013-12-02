class MapController < ApplicationController
  def index
    # This recursively loads things like tileset .tsx files
    tiles = Tmx.load File.join(Rails.root, "public", "terrain-test.tmx")

    @width_in_tiles = tiles.width
    @height_in_tiles = tiles.height
    @tile_width_in_pixels = tiles.tilewidth
    @tile_height_in_pixels = tiles.tileheight

    # Map from layer tile numbers to tileset tile numbers
    data = tiles.layers.first.data
    firstgid = tiles.tilesets.first.firstgid
    data.map! { |tilenum| tilenum - firstgid }
    @tile_data = data.each_slice(@width_in_tiles).to_a

    @tileset_image = tiles.tilesets.first.image

  end
end
