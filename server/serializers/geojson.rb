
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
    @objects.each do |node|
      # layers = {}
      # node[:layers].each do |name, layer|
      #   layers[name] = {
      #     data: layer
      #   }
      #   #puts layer.inspect
      #   #layers[node_datum[:laye]] = node_datum[:data]
      # end
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