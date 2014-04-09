class CdkJSONSerializer < Serializer::Base

  def self.start
    @result = @meta
  end
  
  def self.end
    @result
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
      result = {
        name: layer[:name],
        title: layer[:title],
        description: layer[:description],
        category: layer[:category],
        organization: layer[:organization],
        data_sources: layer[:data_sources],
        #realtime: layer[:realtime],
        update_rate: layer[:update_rate],
        webservice: layer[:webservice],
        imported_at: layer[:imported_at],
        context: layer[:context],
        bbox: layer[:geojson] ? layer[:geojson] : nil
      }
      result.delete_if { |k, v| v.nil? }
      @result[:results] << result
    end
  end
  
  def self.status
    # Status
    # return { :status => 'success', 
    #   :url => request.url, 
    #   "name" => "CitySDK Version 1.0",
    #   "description" => "live testing; preliminary documentation @ http://dev.citysdk.waag.org",
    #   "health" => {
    #     "kv8" => kv8 ? "alive, #{kv8}" : "dead",
    #     "divv" => divv ? "alive, last timestamp: #{divv}" : "dead",
    #   }

    @result.merge @data
  end  
  
end