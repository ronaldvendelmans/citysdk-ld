
class GeoJSONSerializer < Serializer::Base
    
  def self.start
    @geojson = {
      type: "FeatureCollection",
      meta: @meta,
      features: []
    }
  end
  
  def self.end
    @geojson.to_json
  end
  
  def self.nodes
    @objects.each do |node|
      @geojson[:features] << {
        type: "Feature",
        properties: {            
          cdk_id: node[:cdk_id],
          name: node[:name],
          layer: node[:layer],
          layers: node[:layers]
        },
        geometry: node[:geom]
      }
    end    
  end

  # def status
  # end 
  #
  # def nodedatum
  # end
  # 
  # def layer
  # end
  # 
  # def message
  # end

end