
class JSONLDSerializer < GeoJSONSerializer

  #https://code.google.com/p/linked-data-api/wiki/API_Viewing_Resources#Page_Description

  def self.end
    # @result[:meta] = {
    #   :"@type" => ":ApiResultMeta"
    # }.merge @result[:meta]

    case @type
    when :node, :nodes
      @result = {
        :@context => create_node_context,
        :@id => @result[:meta][:url],
        :@type => ":APIResult",
      }.merge @result

      jsonld_nodes
    when :layer, :layers
      @result = {
        :@context => create_layer_context,
        :@id => @result[:meta][:url],
        :@type => ":APIResult",
      }.merge @result

      jsonld_layers
    end

    super
  end

  def self.jsonld_nodes
    # TODO: add fields!!!

    first = true
    @result[:features].map! do |feature|
      cdk_id = feature[:properties][:cdk_id]
      feature[:properties] = {
        :@id => ":objects/#{cdk_id}"
      }.merge feature[:properties]

      feature[:properties][:layer] = ":layers/#{feature[:properties][:layer]}"

      if feature[:properties].has_key? :layers
        feature[:properties][:layers].each do |l,layer|

          layer[:layer] = ":layers/#{l}"

          layer = {
            :@id => ":layers/#{l}/objects/#{cdk_id}",
            :@type => ":LayerOnObject",
          }.merge layer

          # TODO: url from config
          context = "http://api.citysdk.waag.org/layers/#{l}/fields"
          if first
            context = @layers[l][:context] if @layers[l][:context]
          end

          layer[:data] = {
            :@id => ":objects/#{cdk_id}/layers/#{l}",
            :@type => ":LayerData",
            :@context => context,
          }.merge layer[:data]

          feature[:properties][:layers][l] = layer
        end
      end

      first = false

      {
        :"@id" => ":objects/#{cdk_id}",
        :"@type" => ":Object",
      }.merge feature
    end
  end

  def self.jsonld_layers
    first_feature = true
    @result[:features].map! do |feature|
      feature[:properties] = {
        :@id => ":layers/#{feature[:properties][:name]}"
      }.merge feature[:properties]

      {
        :"@id" => ":layers/#{feature[:properties][:name]}",
        :"@type" => [":Layer", "dcat:Dataset"]
      }.merge feature
    end
  end

  def self.create_node_context
    # TODO: set correct base, and use config.json
    {
      :@base => "http://rdf.citysdk.eu/ams/",
      :name => "dc:title",
      :cdk_id => ":cdk_id",
      :features => ":apiResult",
      :properties => "_:properties",
      :date_created => "dc:date",
      :layer => {
        :@id => ":createdOnLayer",
        :@type => "@id"
      },
      :layers => {
        :@id => ":layerOnObject",
        :@container => "@index"
      },
      :data => ":layerData"
      #:wkt => "geos:hasGeometry"
    }
  end

  def self.create_layer_context
    {
      :@base => "http://rdf.citysdk.eu/ams/",
      :title => "dct:title",
      :features => ":apiResult",
      :properties => "_:properties",
      :imported_at => "dct:modified"
    }
  end

end
