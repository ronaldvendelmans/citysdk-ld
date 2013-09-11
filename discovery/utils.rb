require 'rgeo'
require 'rgeo-geojson'


module Sequel
  class Dataset
    def layer_geosearch(params)
      if (params.has_key? 'lat' and params.has_key? 'lon') or params.has_key? 'll'
        if params.has_key?('ll') 
           a = params["ll"].split(',')
           lat,lon = a[0],a[1]
         else
           lat,lon = params["lat"], params["lon"]
         end
        return self.where("ST_Intersects( ST_SetSRID( ST_Point(#{lon}, #{lat}), 4326 ),bbox)" )
      end
      self
    end
  end
end


def parse_request_json(request)
  begin  
    return JSON.parse(request.body.read, {:symbolize_names => true})
  rescue => exception
    throw(:halt, [422, {'Content-Type' => 'application/json'}, {:status => 'fail', :message  => "Error parsing JSON - " + exception.message}.to_json])
  end
end

def save_object(obj)
  begin  
    obj.save
  rescue => exception
    throw(:halt, [422, {'Content-Type' => 'application/json'}, {:status => 'fail', :message  => "Error saving #{obj.class} - " + exception.message}.to_json])
  end
end


$wkb_generator = RGeo::WKRep::WKBGenerator.new({
  :type_format => :ewkb,
  :hex_format => true,
  :emit_ewkb_srid => true 
})  

def makeGeom(bbox)
  # puts bbox
  # puts JSON.pretty_generate(bbox)
  
  geom = RGeo::GeoJSON.decode(bbox.to_json, :json_parser => :json)   
  wkb = $wkb_generator.generate(geom)
  return Sequel.function(:ST_SetSRID, Sequel.lit("'#{wkb}'").cast(:geometry), 4326)
end



def update_layer(ep,l)
  layer = Layer.where({:endpoint_id => ep, :name => l[:name]}).first
  layer = Layer.new({:name => l[:name], :endpoint_id => ep}) if layer.nil?
  if l[:bbox]
    layer.description = l[:description]
    layer.category = l[:category]
    layer.sample_url = l[:sample_url]
    layer.bbox = makeGeom(l[:bbox])
    save_object(layer)
  end
end

def update(code)
  ep = Endpoint.where(:code => code).first
  if ep and ep.type == 'csdk_mobility'
    puts JSON.pretty_generate(ep)
    page = 0
    api = CitySDK::API.new(ep.api.gsub('http://',''))
    begin
      page = page + 1
      layers = api.get("/layers?geom&page=#{page}")
      break if layers[:status] != 'success'
      layers[:results].each do |l|
        update_layer(ep.id,l)
      end
    end while(layers[:next_page].to_i != -1)
  end
end

def update_all
  Endpoint.each do |ep|
    update(ep.code)
  end
end

