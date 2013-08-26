require 'sequel/model'
require 'sequel/plugins/serialization'
require 'set'
require 'json'

require_relative 'node.rb'

class NodeDatum < Sequel::Model
  many_to_one :node
  many_to_one :layer

	plugin :validation_helpers
  
  # hash = {
  #   :name => :plop,
  #   :id => 123,
  #   'addr1:str'=>'kj',
  #   'addr1:num'=>1
  # }
  # 

  KEY_SEPARATOR = ':'
  
  def self.atonestedh(a,v,h)
    begin
      g = h
      while(a.length > 1 )
        aa = a.shift.to_sym
        if g[aa].nil?
          g[aa] = {} 
        elsif g[aa].class == String
          g[aa] = {'->' => g[aa]} 
        end
        g = g[aa]
      end
      g[a[0].to_sym] = v
      h
    rescue => e
      puts e.message;
    end
  end

  def self.nest(h)
    xtra = {}
    h.each_key do |k|
      i = k.to_s.index(KEY_SEPARATOR)
      if i
        a = k.to_s.split(KEY_SEPARATOR)
        atonestedh(a,h[k],xtra)
        h.delete(k)
        h.delete(a[0]) if h[a[0]]
        xtra.each_key do |k|
          xtra[k]['->'] = h[k] if (h[k] and h[k].class == String)
        end
        h = h.merge(xtra)
      end
    end
    h
  end
  
  # deal with osm rdf mapping separately...
  def self.osmprops(h,datas,triples,params)
    h.each do |k,v|

      o = OSMProps.where({:key => k,:val => v}).first
      if(o)
        triples << "\t #{o[:type]} #{o[:uri]} ;"
        next
      end

      o = OSMProps.where(:key => k).where(Sequel.~(:lang => nil)).first
      if(o)
        triples << "\t #{o[:uri]} \"#{v}\"@#{o[:lang]} ;"
        next
      end

      o = OSMProps.where({:type => 'string', :key => k}).where(Sequel.~(:uri => nil)).first
      if(o)
        triples << "\t #{o[:uri]} \"#{v}\" ;"
        next
      end

      o = OSMProps.where({:type => 'a', :key => k}).where(Sequel.~(:uri => nil)).first
      if(o)
        triples << "\t #{o[:type]} #{o[:uri]} ;"
        next
      end

      o = OSMProps.where(:key => k).where(Sequel.~(:type => nil)).first
      if(o)
        triples << "\t #{o[:uri]} \"#{v}\"^^xsd:#{o[:type]} ;"
        next
      end
      
      prop = "<osm.#{k.to_s}>"
      params[:layerdataproperties] << "#{prop} rdfs:subPropertyOf :layerProperty ."
      datas << "\t #{prop} \"#{v}\" ;"

    end # h.each
  end
  
  
  def self.turtelize_one(nd,triples,base_uri,params,cdk_id)
    datas = []
    layer_id = nd[:layer_id]
    name = Layer.textFromId(layer_id)
    subj = base_uri + name

    datas << "<#{subj}>"
    
    if layer_id == 0 

      osmprops(nd[:data].to_hash,datas,triples,params)

    else

      if Layer.isWebservice?(layer_id) and !params.has_key?('skip_webservice')
        nd[:data] = WebService.load(layer_id, cdk_id, nd[:data])
      end

      nd[:data].to_hash.each do |k,v|
        res = LDProps.where({:layer_id => layer_id, :key => k.to_s }).first
        if res
          lng = res[:lang]
          prp = res[:uri]
          tpe = res[:type]
        else
          lng = nil
          tpe = nil
          prp = "<#{name}.#{k.to_s}>"
          # prp = "<#{$config[:ep_code]}.#{name}.#{k.to_s}>"
        end
        params[:layerdataproperties] << "#{prp} rdfs:subPropertyOf :layerProperty ."
        s = "\t #{prp} \"#{v}\""
        s += "^^xsd:#{tpe}" if tpe
        s += "@#{lng}" if lng
        datas << s + " ;"
      end

    end
    
    if datas.length > 1
      triples << "\t :layerData <#{subj}> ;"
      datas[-1][-1] = '.'
      datas << ""
    else 
      datas = []
    end
    return datas
  end
  
  def self.turtelize(cdk_id, h, params)    
    triples = []
    gdatas = []
    params[:layerdataproperties] = Set.new if params[:layerdataproperties].nil?
    base_uri = "#{cdk_id}/"
    h.each do |nd|
      gdatas += self.turtelize_one(nd,triples,base_uri,params,cdk_id)
    end
    
    return triples, gdatas
  end

 
  def self.serialize(cdk_id, h, params)    
    newh = {}
    h.each do |nd|

      layer_id = nd[:layer_id]
      
      name = Layer.textFromId(layer_id)
      
      nd.delete(:validity)
      # rt,vl = Layer.get_validity(layer_id)
      # if(rt)
      #   nd.delete(:validity)
      #   nd[:update_rate] = vl
      # else
      #   nd[:validity] = vl if nd[:validity].nil?
      #   nd[:validity] = [nd[:validity].begin, nd[:validity].end] if nd[:validity]
      # end
      # nd.delete(:validity) if nd[:validity].nil?      
      
      nd.delete(:tags) if nd[:tags].nil?
      
      if nd[:modalities]
        nd[:modalities] = nd[:modalities].map { |m| Modality.NameFromId(m) }
      else
        nd.delete(:modalities)
      end

      nd.delete(:id)
      nd.delete(:node_id)
      nd.delete(:parent_id)
      nd.delete(:layer_id)
      nd.delete(:created_at)
      nd.delete(:updated_at)
      nd.delete(:node_data_type)
      nd.delete(:created_at)
      nd.delete(:updated_at)

      if Layer.isWebservice?(layer_id) and !params.has_key?('skip_webservice')
        nd[:data] = WebService.load(layer_id, cdk_id, nd[:data])
      end
      
      nd[:data] = nest(nd[:data].to_hash)
      newh[name] = nd
    end
    newh
  end
  
end
