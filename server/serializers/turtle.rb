class TurtleSerializer < Serializer::Base

  PREFIXES = {
    :"" => "http://rdf.citysdk.eu/",
    :"rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
    :"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    :"geos" => "http://www.opengis.net/ont/geosparql#",
    :"dc" => "http://purl.org/dc/elements/1.1/",
    :"owl" => "http://www.w3.org/2002/07/owl#",
    :"xsd" => "http://www.w3.org/2001/XMLSchema#",
    :"owl" => "http://www.w3.org/2002/07/owl#",
  }
      
  def self.start
    @result = []
    
    @prefixes = []
    @prefixes << "@base <http://rdf.citysdk.eu/asd/> ."
    PREFIXES.each do |prefix, iri| 
      @prefixes << "@prefix #{prefix}: <#{iri}> ."
    end
  end
  
  def self.end
    (@prefixes.uniq + [""] + @result).join("\n")
  end
  
  def self.nodes
    
    @layers.each do |l, layer|      
      layer[:fields].each do |field|
        @result << "<layers/#{l}/fields/#{field[:id]}>"
        @result << "    :definedOnLayer <layers/#{l}> ;"        
        
        @result << "    rdf:type #{field[:type]} ;" if field[:type]
        @result << "    rdfs:description #{field[:description].to_json} ;" if field[:description]
        @result << "    xsd:language #{field[:lang].to_json} ;" if field[:lang]
        @result << "    owl:equivalentProperty #{field[:eqprop]} ;" if field[:eqprop]
        @result << "    :hasValueUnit #{field[:unit]} ;" if field[:unit]
        
        @result << "    rdfs:subPropertyOf :layerProperty ."
        @result << ""
      end
    end
        
    first = true
    @data.each do |node|
      @result << "" if not first
      @result << "<#{node[:cdk_id]}>"
      @result << "    a :Object ;"
      @result << "    :cdk_id \"#{node[:cdk_id]}\" ;"
      @result << "    dc:title \"#{node[:name]}\" ;" if node[:name]
      @result << "    geos:hasGeometry \"#{node[:geom].round_coordinates(Serializer::PRECISION)}\" ;" if node[:geom]
      @result << "    :createdOnLayer <layers/#{node[:layer]}> ;"
      
      if node.has_key? :layers
        node[:layers].keys.each do |layer|
          s = (layer == node[:layers].keys[-1]) ? '.' : ';'
          @result << "    :layerOnObject <layers/#{layer}/objects/#{node[:cdk_id]}> #{s}"
        end
      end
      @result << ""
     
      if node.has_key? :layers
        node[:layers].keys.each do |layer|
          @result << "<layers/#{layer}/objects/#{node[:cdk_id]}>"
          @result << "    a :LayerOnObject ;"
          @result << "    :layerData <objects/#{node[:cdk_id]}/layers/#{layer}> ;"
          @result << "    :createdOnLayer <layers/#{layer}> ."
          #@result << "    dc:created \"<node datum created date>\"^^xsd:date ."
          
          if @layers[layer][:context]
            jsonld = {
              :"@context" => @layers[layer][:context],
              :"@id" => ":objects/#{node[:cdk_id]}/layers/#{layer}",
              :"@type" => ":LayerData"
            }.merge node[:layers][layer][:data]        
            graph = RDF::Graph.new << JSON::LD::API.toRdf(JSON.parse(jsonld.to_json))
                    
            # Get layer prefixes from JSON-LD context
            # only add first-level values, if they
            # start with http and end with either # or /
            # Afterwards, merge layer prefixes with global
            # PREFIXES
            prefixes = @layers[layer][:context].select { |prefix,iri| 
              prefix != :"@base" and iri.is_a? String and 
              iri.index("http") == 0 and ["/", "#"].include? iri[-1]            
            }.merge PREFIXES
            
            graph.dump(:ttl, :prefixes => prefixes).each_line do |line|
              # Turtle output of graph.dump contains both prefixes statements
              # Filter out prefixes, and add them to @prefixes and rest to @result
              if line.index("@prefix") == 0
                @prefixes << line.strip
              else
                @result << line.rstrip
              end
            end
            
          end
        end
      end
      first = false
    end
        
  end
  
  def self.layers
    first = true
    @data.each do |layer|
      @result << "" if not first
      @result << "<layers/#{layer[:name]}>"
      @result << "    a :Layer, dcat:Dataset ;"
      @result << "    rdfs:label \"#{layer[:name]}\" ;"
      @result << "    dcat:contactPoint ["
      @result << "        "
      #foaf:name "Nijmegen" ;
      #foaf:mbox "chrisvanaart@2coolmonkeys.nl"
      @result << "    ] ;"
      @result << "    geos:hasGeometry \"#{layer[:wkt].round_coordinates(Serializer::PRECISION)}\" ;" if layer[:wkt]

      first = false
    end
    
  end
  
  def self.status
  end  

  # FROM LAYER:
  # res = LayerProperty.where(:layer_id => id)
  # h[:fields] = [] if res.count > 0
  # res.each do |r|
  #   a = {
  #     :key => r.key,
  #     :type => r.type
  #   }
  #   a[:valueUnit]      = r.unit if r.type =~ /(integer|float|double)/ and r.unit != ''
  #   a[:valueLanguange] = r.lang if r.lang != '' and r.type == 'xsd:string'
  #   a[:equivalentProperty] = r.eqprop if r.eqprop and r.eqprop != ''
  #   a[:description]    = r.descr if not r.descr.empty?
  #   h[:fields] << a
  # end
 
  # Status:
  
  # when 'text/turtle'
  #   a = ["@base <#{CDK_BASE_URI}#{Config[:ep_code]}/> ."]
  #   a << "@prefix : <#{CDK_BASE_URI}> ."
  #   a << "@prefix foaf: <http://xmlns.com/foaf/0.1/> ."
  #   a << "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
  #   a << ""
  #   a << '_:ep'
  #   a << ' a :CitysdkEndpoint ;'
  #   a << " rdfs:description \"#{Config[:ep_description]}\" ;"
  #   a << " :endpointCode \"#{Config[:ep_code]}\" ;"
  #   a << " :apiUrl \"#{Config[:ep_api_url]}\" ;"
  #   a << " :cmsUrl \"#{Config[:ep_cms_url]}\" ;"
  #   a << " :infoUrl \"#{Config[:ep_info_url]}\" ;"
  #   a << " foaf:mbox \"#{Config[:ep_maintainer_email]}\" ."
  #   return a.join("\n")
  

end