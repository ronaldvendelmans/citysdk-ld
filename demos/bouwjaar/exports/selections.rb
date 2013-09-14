require 'json'
require 'rgeo/geo_json'
require 'faraday'
require 'fileutils'
require 'stringex'

config = JSON.parse(File.read('./config.json'))

export_path = config["paths"]["exports"]
projects_path = config["paths"]["projects"]
tilemill_path = config["paths"]["tilemill"]
script_path = File.expand_path(File.dirname(__FILE__))

formats = ["png"] # ["pdf", "png"]

r = 0.9 # pixels per meter

rgeo_factory = RGeo::Geographic.spherical_factory(:srid => 3785)

#bbox=xmin,ymin,xmax,ymax
tile_cmd = "#{tilemill_path}/index.js export bag #{export_path}/selections/%s.%s --format=%s --width=%s --height=%s --bbox=%s --files=#{projects_path}"

#3x2
# {
#   "type": "Feature",
#   "properties": {
#     "name": ""
#   },
#   "geometry":
# },  
selections = JSON.parse(File.read('./selections.json'))

Dir.chdir(tilemill_path)
selections["features"].each do |selection|

  name = selection["properties"]["name"]  
  filename = name.downcase.to_ascii.gsub(/[^a-z]/, "_")
  
  geom = RGeo::GeoJSON.decode(selection["geometry"].to_json, :json_parser => :json)
  bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(geom)

  bbox_str = [
    bbox.min_x(),
    bbox.min_y(),
    bbox.max_x(),
    bbox.max_y()
  ].join(",")
      
  sw = rgeo_factory.point(bbox.min_x(), bbox.min_y())
  se = rgeo_factory.point(bbox.max_x(), bbox.min_y())
  nw = rgeo_factory.point(bbox.min_x(), bbox.max_y())

  dx = sw.distance(se).round
  dy = sw.distance(nw).round
 
  puts "Rendering #{name}, #{dx / 1000} bij #{dy / 1000} km." 
     
  formats.each { |format| 
    puts tile_cmd % [filename, format, format, (r * dx).round, (r * dy).round, bbox_str] 
    system tile_cmd % [filename, format, format, (r * dx).round, (r * dy).round, bbox_str] 
  }
  
  puts "Converting #{name} to jpg"
  
  system "convert #{export_path}/selections/#{filename}.png -resize \"8000x8000>\" -colorspace sRGB -quality 99 #{export_path}/selections/#{filename}.jpg"

end

puts "Done..."

