class TurtleSerializer < Serializer::Base

  # TODO: v0.9 included description and uses owl:equivalentProperty
  # v1.0 for now uses only JSON-LD context field. See how description can be added!
  # 
  # <2cm.bomen.rotterdam/Naam>
  #    :definedOnLayer <layer/2cm.bomen.rotterdam> ;
  #    rdfs:subPropertyOf :layerProperty ;
  #    owl:equivalentProperty dc:title .
  # 
  # <rws.nap/waarde>
  #    :definedOnLayer <layer/rws.nap> ;
  #    rdfs:subPropertyOf :layerProperty ;
  #    rdfs:description "Water level in millimeter above NAP, Amsterdam Ordnance Datum (http://en.wikipedia.org/wiki/Amsterdam_Ordnance_Datum)" ;
  #    :hasValueUnit csdk:unitMilliMeter .
  
  def self.start
    @result = []
    @result << <<-RDF
@base <http://rdf.citysdk.eu/asd/> .
@prefix : <http://rdf.citysdk.eu/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix geos: <http://www.opengis.net/ont/geosparql#> .
@prefix dc: <http://purl.org/dc/elements/1.1/> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
    RDF
       
  end
  
  def self.end
    @result.join("\n")
  end
  
  def self.nodes
    # TODO: Check ALL nodes, not only first...
    node = @data.first
    if node.has_key? :layers 
      node[:layers].keys.each do |layer|
        node[:layers][layer][:data].keys.each do |field|          
          @result << "<layers/#{layer}/fields/#{field}>"
          @result << "    :definedOnLayer <layers/#{layer}> ;"
          @result << "    rdfs:subPropertyOf :layerProperty ."          
        end
      end
    end
    
    @data.each do |node|
      @result << ""
      @result << "<#{node[:cdk_id]}>"
      @result << "    a :Object ;"
      @result << "    dc:title \"#{node[:name]}\" ;"
      @result << "    :createdOnLayer <layers/#{node[:layer]}> ;"
      if node.has_key? :layers
        node[:layers].keys.each do |layer|
          s = (layer == node[:layers].keys[-1]) ? '.' : ';'
          @result << "    :layerOnObject <layers/#{layer}/objects/#{node[:cdk_id]}> #{s}"
        end
      end
     
      if node.has_key? :layers
        node[:layers].keys.each do |layer|
          @result << "<layers/#{layer}/objects/#{node[:cdk_id]}>"
          @result << "    a :LayerOnObject ;"
          @result << "    :layerData <objects/#{node[:cdk_id]}/layers/#{layer}> ;"
          @result << "    :createdOnLayer <layers/#{layer}> ;"
          @result << "    dc:created \"1954-11-14\"^^xsd:date ."
          @result << "<objects/#{node[:cdk_id]}/layers/#{layer}>"
          @result << "    a :LayerData ;"
          node[:layers][layer][:data].keys.each do |field|
          s = (field == node[:layers][layer][:data].keys[-1]) ? '.' : ';'            
            @result << "    <layers/#{layer}/fields/#{field}> \"#{node[:layers][layer][:data][field]}\" #{s}"
          end
        end
      end
    end
        
  end
  
  def self.layers
    
    # a dcat:Dataset ;
    #        dct:title "Imaginary dataset" ;
    #        dcat:keyword "accountability","transparency" ,"payments" ;
    #        dct:issued "2011-12-05"^^xsd:date ;
    #        dct:modified "2011-12-05"^^xsd:date ;
    #        dcat:contactPoint <http://example.org/transparency-office/contact> ;
    #        dct:temporal <http://reference.data.gov.uk/id/quarter/2006-Q1> ;
    #        dct:spatial <http://www.geonames.org/6695072> ;
    #        dct:publisher :finance-ministry ;
    #        dct:language <http://id.loc.gov/vocabulary/iso639-1/en>  ;
    #        dct:accrualPeriodicity <http://purl.org/linked-data/sdmx/2009/code#freq-W>  ;
    #        dcat:distribution :dataset-001-csv ;
    
  end
 
  # def message
  # end
  
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
  
  
  # End:
  #   when 'text/turtle'
  #     begin
  #       return [self.prefixes.join("\n"),self.layerProps(params),@@noderesults.join("\n")].join("\n")
  #     rescue Exception => e
  #       ::CitySDK_API::do_abort(500,"Server error (#{e.message}, \n #{e.backtrace.join('\n')}.")
  #     end
  #   end
  
  
  # def self.processPredicate(n,params)
  #   p = params[:p]
  #   layer,field = p.split('/')
  #   if 0 == Layer.where(:name=>layer).count
  #     CitySDK_API.do_abort(422,"Layer not found: 'layer'")
  #   end
  #   layer_id = Layer.id_from_text(layer)
  #   nd = NodeDatum.where({:node_id => n[:id], :layer_id => layer_id}).first
  #   if nd
  #     # puts JSON.pretty_generate(nd[:data])
  #     case params[:request_format]
  #     when'application/json'
  #       @@noderesults << {field => nd[:data][field.to_sym]}
  #     when'text/turtle'
  #       @@noderesults = NodeDatum.turtelizeOneField(n[:cdk_id],nd,field,params)
  #     end
  #   end
  # end 
  
  
  
  
  
  
  
  
  # Node:
  
  # def self.turtelize(h,params)    
  #   @@prefixes << 'rdfs:'
  #   @@prefixes << 'rdf:'
  #   @@prefixes << 'geos:'
  #   @@prefixes << 'dc:'
  #   @@prefixes << 'owl:'
  #   @@prefixes << 'lgdo:' if h[:layer_id] == 0
  #   triples = []
  #   
  #   if not @@layers.include?(h[:layer_id])
  #     @@layers << h[:layer_id]
  #     triples << "<layer/#{Layer.name_from_id(h[:layer_id])}> a :Layer ."
  #     triples << ""
  #   end
  #   
  #   triples << "<#{h[:cdk_id]}>"
  #   triples << "\t a :#{@@node_types[h[:node_type]].capitalize} ;"
  #   triples << "\t dc:title \"#{h[:name].gsub('"','\"')}\" ;" if h[:name] and h[:name] != ''
  #   triples << "\t :createdOnLayer <layer/#{Layer.name_from_id(h[:layer_id])}> ;"
  #   
  #   if h[:modalities]
  #     h[:modalities].each { |m| 
  #       triples << "\t :hasTransportmodality :transportModality_#{Modality.name_from_id(m)} ;"
  #     }
  #   end    
  #   
  #   if h[:geom]
  #     triples << "\t geos:hasGeometry \"" + h[:geom].round_coordinates(PRECISION) + "\" ;"
  #   end
  # 
  #   if h[:node_data]
  #     t,d =  NodeDatum.turtelize(h[:cdk_id], h[:node_data], params) 
  #     triples += t if t
  #     triples += d if d
  #   end
  #   
  # 
  #   @@noderesults += triples
  #   @@noderesults[-1][-1]='.' if @@noderesults[-1] and @@noderesults[-1][-1] == ';'
  #   triples
  #   
  # end
  
  
  
  
  # def self.prefixes
  #   prfs = ["@base <#{::CitySDK_API::CDK_BASE_URI}#{::CitySDK_API::Config[:ep_code]}/> ."]
  #   prfs << "@prefix : <#{::CitySDK_API::CDK_BASE_URI}> ."
  #   @@prefixes.each do |p|
  #     prfs << "@prefix #{p} <#{Prefix.where(:prefix => p).first[:url]}> ." 
  #   end
  #   prfs << ""
  # end
  # 
  # def self.layerProps(params)
  #   pr = []
  #   if params[:layerdataproperties]
  #     params[:layerdataproperties].each do |p|
  #       pr << p
  #     end
  #     pr << ""
  #   end
  #   pr
  # end

end