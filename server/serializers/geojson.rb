
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
    @data.each do |node|
      feature = {
        type: "Feature",
        properties: {            
          cdk_id: node[:cdk_id],
          name: node[:name],
          layer: node[:layer]          
        },
        geometry: node[:geom] ? JSON.parse(node[:geom].round_coordinates(Serializer::PRECISION)) : {}
      }
      feature[:properties][:layers] = node[:layers] if node.has_key? :layers and node[:layers] 
      @geojson[:features] << feature
    end
  end

  def self.layers    
    @data.each do |layer|
      feature = {
        type: "Feature",
        properties: {        
          name: layer[:name],
          title: layer[:title],
          description: layer[:description],
          category: layer[:category],
          organization: layer[:organization]
          # data_sources: layer[:data_sources]
        },
        geometry: layer[:bbox] ? JSON.parse(layer[:bbox].round_coordinates(Serializer::PRECISION)) : {}
      }
      @geojson[:features] << feature
    end
  end
  # 
  # def message
  # end
  
  def self.status
    @geojson[:features] << @data
  end  

end