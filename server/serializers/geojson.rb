
class GeoJSONSerializer < Serializer::Base
    
  def self.start
    @result = {
      type: "FeatureCollection",
      meta: @meta,
      features: []
    }
  end
  
  def self.end
    @result.to_json
  end
  
  def self.nodes
    @data.each do |node|
      feature = {
        type: "Feature",
        properties: {            
          cdk_id: node[:cdk_id],
          name: node[:name],
          node_type: nil,
          layer: node[:layer]          
        },
        geometry: node[:geom] ? JSON.parse(node[:geom].round_coordinates(Serializer::PRECISION)) : {}
      }
      feature[:properties][:layers] = node[:layers] if node.has_key? :layers and node[:layers] 
      @result[:features] << feature
    end
  end

  def self.layers    
    @data.each do |layer|
      @result[:features] << {
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
    end
  end
  # 
  # def message
  # end
  
  def self.status
    @result[:features] << {
      type: "Feature",
      properties: @data,
      geometry: @data[:geometry]
    }
  end  

end