require 'set'

class Sequel::Model
  @@node_types = ['node','route','ptstop','ptline']  
  @@noderesults = []
  @@prefixes = Set.new
  @@layers = []
end


class Node < Sequel::Model
  #plugin :validation_helpers
  one_to_many :node_data

  def self.processPredicate(n,params)
    p = params[:p]
    layer,field = p.split('/')
    if 0 == Layer.where(:name=>layer).count
      CitySDK_API.do_abort(422,"Layer not found: 'layer'")
    end
    layer_id = Layer.idFromText(layer)
    nd = NodeDatum.where({:node_id => n[:id], :layer_id => layer_id}).first
    if nd
      # puts JSON.pretty_generate(nd[:data])
      case params[:request_format]
      when'application/json'
        @@noderesults << {field => nd[:data][field.to_sym]}
      when'text/turtle'
        @@noderesults = NodeDatum.turtelizeOneField(n[:cdk_id],nd,field,params)
      end
    end
  end
  

  def getLayer(n)
    if n.is_a?(String)
      self.node_data.each do |nd|
        return nd if nd.layer.name == n
      end
    else
      self.node_data.each do |nd|
        return nd if nd.layer_id == n
      end
    end
    nil
  end
  
  
  def self.serializeStart(params,request)
    case params[:request_format]
    when 'application/json'
      @@noderesults = []
    when 'text/turtle'
      @@noderesults = []
      @@prefixes = Set.new
      @@layers = []
    end
  end
    
  def self.prefixes
    prfs = ["@base <#{::CitySDK_API::CDK_BASE_URI}#{::CitySDK_API::Config[:ep_code]}/> ."]
    prfs << "@prefix : <#{::CitySDK_API::CDK_BASE_URI}> ."
    @@prefixes.each do |p|
      prfs << "@prefix #{p} <#{Prefix.where(:prefix => p).first[:url]}> ." 
    end
    prfs << ""
  end
  
  def self.layerProps(params)
    pr = []
    if params[:layerdataproperties]
      params[:layerdataproperties].each do |p|
        pr << p
      end
      pr << ""
    end
    pr
  end
  
  def self.serializeEnd(params,request, pagination = {})

    case params[:request_format]
    when 'application/json'
      { :status => 'success',
        :url => request.url
      }.merge(pagination).merge({
        :results => @@noderesults
      }).to_json

    when 'text/turtle'
      begin
        return [self.prefixes.join("\n"),self.layerProps(params),@@noderesults.join("\n")].join("\n")
      rescue Exception => e
        ::CitySDK_API::do_abort(500,"Server error (#{e.message}, \n #{e.backtrace.join('\n')}.")
      end
    end


  end
  

  def self.serialize(h,params)
    case params[:request_format]
    when 'application/json'
      Node.make_hash(h,params)    
    when 'text/turtle'
      Node.turtelize(h,params)    
    end
  end
  

  def self.make_hash(h,params)    
    h[:layers] = NodeDatum.serialize(h[:cdk_id], h[:node_data], params) if h[:node_data]

    # members not directly exposed, 
    # call ../ptstops form members of route, f.i.
    h.delete(:members)

    h[:layer] = Layer.nameFromId(h[:layer_id])
    h[:name] = '' if h[:name].nil?
    if h[:geom]
      h[:geom] = JSON.parse(h[:geom].round_coordinates(6))
    end
    
    if h[:modalities]
      h[:modalities] = h[:modalities].map { |m| Modality.NameFromId(m) }
    else
      h.delete(:modalities)
    end

    h.delete(:related) if h[:related].nil?    
    #h.delete(:modalities) if (h[:modalities] == [] or h[:modalities].nil?)
    h[:node_type] = @@node_types[h[:node_type]]
    h.delete(:layer_id)
    h.delete(:id)
    h.delete(:node_data)
    h.delete(:created_at)
    h.delete(:updated_at)

    @@noderesults << h
    h
  end
  
  
  def self.turtelize(h,params)    
    @@prefixes << 'rdfs:'
    @@prefixes << 'rdf:'
    @@prefixes << 'geos:'
    @@prefixes << 'dc:'
    @@prefixes << 'owl:'
    @@prefixes << 'lgdo:' if h[:layer_id] == 0
    triples = []
    
    if not @@layers.include?(h[:layer_id])
      @@layers << h[:layer_id]
      triples << "<layer/#{Layer.nameFromId(h[:layer_id])}> a :Layer ."
      triples << ""
    end
    
    triples << "<#{h[:cdk_id]}>"
    triples << "\t a :#{@@node_types[h[:node_type]].capitalize} ;"
    triples << "\t dc:title \"#{h[:name].gsub('"','\"')}\" ;" if h[:name] and h[:name] != ''
    triples << "\t :createdOnLayer <layer/#{Layer.nameFromId(h[:layer_id])}> ;"
    
    if h[:modalities]
      h[:modalities].each { |m| 
        triples << "\t :hasTransportmodality :transportModality_#{Modality.NameFromId(m)} ;"
      }
    end    
    
    if h[:geom]
      triples << "\t geos:hasGeometry \"" + h[:geom].round_coordinates(6) + "\" ;"
    end

    if h[:node_data]
      t,d =  NodeDatum.turtelize(h[:cdk_id], h[:node_data], params) 
      triples += t if t
      triples += d if d
    end
    

    @@noderesults += triples
    @@noderesults[-1][-1]='.' if @@noderesults[-1] and @@noderesults[-1][-1] == ';'
    triples
    
  end
  

end

