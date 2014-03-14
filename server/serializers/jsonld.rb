
class JSONLDSerializer < GeoJSONSerializer
    
  #https://code.google.com/p/linked-data-api/wiki/API_Viewing_Resources#Page_Description
  
  def self.end
    # @result[:meta] = {
    #   :"@type" => "cdk:ApiResultMeta"
    # }.merge @result[:meta]
    
    case @type    
    when :node, :nodes
      @result = {
        :@context => create_node_context,
        :@id => @result[:meta][:url],
        :@type => "cdk:APIResult",
      }.merge @result      
      
      jsonld_nodes
    when :layer, :layers      
      @result = {
        :@context => create_layer_context,
        :@id => @result[:meta][:url],
        :@type => "cdk:APIResult",
      }.merge @result      
      
      jsonld_layers
    end
    
    super
  end
  
  def self.jsonld_nodes
    first_feature = true
    @result[:features].map! do |feature|      
      cdk_id = feature[:properties][:cdk_id]
      feature[:properties] = {
        :@id => "cdk:objects/#{cdk_id}"
      }.merge feature[:properties]
      
      feature[:properties][:layer] = "cdk:layers/#{feature[:properties][:layer]}"
      
      feature[:properties][:layers].each do |l,layer|
        layer[:layer] = "cdk:layers/#{l}"
        
        layer = {
          :@id => "cdk:layers/#{l}/objects/#{cdk_id}",
          :@type => "cdk:LayerOnObject",          
        }.merge layer
        
        context = "http://api.citysdk.waag.org/layers/#{l}/fields"
        if first_feature
          context = @layers[l][:context] if @layers[l][:context]
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
  end
  
  def self.jsonld_layers
    first_feature = true
    @result[:features].map! do |feature|
      feature[:properties] = {
        :@id => "cdk:layers/#{feature[:properties][:name]}"
      }.merge feature[:properties]

      {
        :"@id" => "cdk:layers/#{feature[:properties][:name]}",
        :"@type" => ["cdk:Layer", "dcat:Dataset"]
      }.merge feature
    end
  end  
  
  def self.create_node_context
    # TODO: set correct base, and use config.json
    {      
      :@base => "http://rdf.citysdk.eu/ams/",
      :name => "dc:title",
      :cdk_id => "cdk:cdk_id",
      :features => "cdk:apiResult",
      :properties => "_:properties",
      :date_created => "dc:date",
      :layer => {
        :@id => "cdk:createdOnLayer",
        :@type => "@id"        
      },
      :layers => {
        :@id => "cdk:layerOnObject",
        :@container => "@index"
      },
      :data => "cdk:layerData"
      #:wkt => "geos:hasGeometry"
    }
  end
  
  def self.create_layer_context    
    {
      :@base => "http://rdf.citysdk.eu/ams/",
      :title => "dct:title",
      :features => "cdk:apiResult",
      :properties => "_:properties",
      :imported_at => "dct:modified"
    }
  end

end
