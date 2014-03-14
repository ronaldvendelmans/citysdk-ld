
class JSONLDSerializer < GeoJSONSerializer
    
  #https://code.google.com/p/linked-data-api/wiki/API_Viewing_Resources#Page_Description
  
  def self.end
    @result = {
      :@context => create_context,
      :@id => @result[:meta][:url],
      :@type => "cdk:APIResult",
    }.merge @result

    # @result[:meta] = {
    #   :"@type" => "cdk:ApiResultMeta"
    # }.merge @result[:meta]
    
    first_feature = true
    @result[:features].map! do |feature| 
      cdk_id = feature[:properties][:cdk_id]
      feature[:properties] = {
        :@id => "cdk:objects/#{cdk_id}"
      }.merge feature[:properties]
      
      feature[:properties][:layers].each do |l,layer|
        layer = {
          :@id => "cdk:layers/#{l}/objects/#{cdk_id}",
          :@type => "cdk:LayerOnObject",
        }.merge layer
        
        context = "http://api.citysdk.waag.org/layers/#{l}/fields"
        if first_feature
          c = create_layer_context @layers[l]
          context = c if c
        end
        
        layer[:data] = {
          :@id => "cdk:objects/#{cdk_id}/layers/#{l}",
          :@type => "cdk:LayerData",
          :@context => context,
        }.merge layer[:data]
        
        feature[:properties][:layers][l] = layer
      end
      
      first_feature = false
      
      {
        :"@id" => "cdk:objects/#{cdk_id}",
        :"@type" => "cdk:Object",
      }.merge feature
    end
    
    super
  end
  
  def self.create_context
    # TODO: set correct base, and use config.json
    {      
      :@base => "http://rdf.citysdk.eu/ams/",
      :name => "dc:title",
      :cdk_id => "cdk:cdk_id",
      :features => "cdk:apiResult",
      :properties => "_:properties",
      :date_created => "dc:date",
      :layers => {
        :@id => "cdk:layerOnObject",
        :@container => "@index"
      },
      :data => "cdk:layerData"
      #:wkt => "geos:hasGeometry"
    }
  end
  
  def self.create_layer_context(layer)
    if layer[:context]
      return layer[:context]
    end
    nil
  end

end
