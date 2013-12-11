class MapController < ApplicationController
  def index
    terrain_name = params[:terrain] || ""
    terrain_name = "goldenfields_house1" unless terrain_name =~ /^[-a-zA-Z0-9_]+$/

    # This recursively loads things like tileset .tsx files
    tiles = Tmx.load File.join(Rails.root, "terrains", "#{terrain_name}.tmx")

    @width_in_tiles = tiles.width
    @height_in_tiles = tiles.height
    @tile_width_in_pixels = tiles.tilewidth
    @tile_height_in_pixels = tiles.tileheight

    # Tilesets
    @tilesets = tiles.tilesets.map do |tileset|
      {
        firstgid: tileset.firstgid,
        url: "/tiles/" + tileset.image.split("/")[-1],
        image_width: tileset.imagewidth,
        image_height: tileset.imageheight,
        tile_width: tileset.tilewidth,
        tile_height: tileset.tileheight,
        properties: tileset.properties,
      }
    end

    @tile_layers = tiles.layers.map do |layer|
      data = layer.data.each_slice(layer.width).to_a
      {
        name: layer.name,
        data: data,
        visible: layer.visible,
        opacity: layer.opacity,
      }
    end

    # Old hardcoding of single terrain layer and tileset
    data = tiles.layers.first.data
    firstgid = tiles.tilesets.first.firstgid
    data.map! { |tilenum| tilenum - firstgid }
    @tile_data = data.each_slice(@width_in_tiles).to_a

    @tileset_image = tiles.tilesets.first.image

  end
end
