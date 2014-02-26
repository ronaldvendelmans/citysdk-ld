class CdkJSONSerializer < Serializer::Base

  def self.start
    @result = @meta
  end
  
  def self.end
    @result.to_json
  end
  
  def self.nodes
    @result[:results] =  []
    @data.each do |node|
      result = {
        cdk_id: node[:cdk_id],
        name: node[:name],
        node_type: node[:node_type]
      }
      result[:geom] = JSON.parse(node[:geom].round_coordinates(Serializer::PRECISION)) if node[:geom]
      result[:layers] = node[:layers] if node.has_key? :layers and node[:layers] 
      result[:layer] = node[:layer]          
      @result[:results] << result
    end
  end

  def self.layers
    @result[:results] =  []    
    @data.each do |layer|
      @result[:results] << {
        name: layer[:name],
        title: layer[:title],
        description: layer[:description],
        category: layer[:category],
        organization: layer[:organization],
        # data_sources: layer[:data_sources]
        geom: layer[:bbox] ? JSON.parse(layer[:bbox].round_coordinates(Serializer::PRECISION)) : {}
      }  
    end
  end
  # 
  # def message
  # end
  
  def self.status
    @result.merge @data
  end  
  
  # Status
  # return { :status => 'success', 
  #   :url => request.url, 
  #   "name" => "CitySDK Version 1.0",
  #   "description" => "live testing; preliminary documentation @ http://dev.citysdk.waag.org",
  #   "health" => {
  #     "kv8" => kv8 ? "alive, #{kv8}" : "dead",
  #     "divv" => divv ? "alive, last timestamp: #{divv}" : "dead",
  #   }
  
  
  #node end
  #   case params[:request_format]
  #   when 'application/json'
  #     { :status => 'success',
  #       :url => request.url
  #     }.merge(pagination).merge({
  #       :results => @@noderesults
  #     }).to_json
  # 
  
end