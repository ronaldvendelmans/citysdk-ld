class TurtleSerializer < Serializer::Base

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