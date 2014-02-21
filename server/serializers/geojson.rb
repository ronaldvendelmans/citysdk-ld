
class GeoJSONSerializer < Serializer::Base
    
  def self.start
    @geojson = {
      type: "FeatureCollection",
      meta: {},
      features: []
    }
  end
  
  def self.end
    @geojson.to_json
  end
  
  def self.nodes
    puts @@objects.first.inspect
  end

  # def status
  # end
  # 

  # 
  # def nodedatum
  # end
  # 
  # def layer
  # end
  # 
  # def message
  # end
  # 

end