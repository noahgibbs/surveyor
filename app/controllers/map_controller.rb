class MapController < ApplicationController
  def index
    # This recursively loads things like tileset .tsx files
    tiles = Tmx.load File.join(Rails.root, "terrains", "terrain-test.tmx")

    @width_in_tiles = tiles.width
    @height_in_tiles = tiles.height
    @tile_width_in_pixels = tiles.tilewidth
    @tile_height_in_pixels = tiles.tileheight

    # Tilesets
    @tilesets = tiles.tilesets.map do |tileset|
      [tileset.firstgid, "/tiles/" + tileset.image.split("/")[-1],
       tileset.imagewidth, tileset.imageheight, tileset.properties]
    end

    @tile_layers = tiles.layers.map do |layer|
      data = layer.data.each_slice(layer.width).to_a
      [layer.name, data]
    end

    # Old hardcoding of single terrain layer and tileset
    data = tiles.layers.first.data
    firstgid = tiles.tilesets.first.firstgid
    data.map! { |tilenum| tilenum - firstgid }
    @tile_data = data.each_slice(@width_in_tiles).to_a

    @tileset_image = tiles.tilesets.first.image

  end
end
