class MapController < ApplicationController
  def index
    terrain_name = params[:terrain] || ""
    terrain_name = "goldenfields_house1" unless terrain_name =~ /^[-a-zA-Z0-9_]+$/

    @terrain_names = Dir[File.join(Rails.root, "terrains", "*.tmx")].map { |s| File.basename(s, ".tmx") }

    # This recursively loads things like tileset .tsx files
    tiles = Tmx.load File.join(Rails.root, "terrains", "#{terrain_name}.tmx")

    @width_in_tiles = tiles.width
    @height_in_tiles = tiles.height
    @tile_width_in_pixels = tiles.tilewidth
    @tile_height_in_pixels = tiles.tileheight

    @viewport_width = 30
    @viewport_height = 30

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
  end
end
