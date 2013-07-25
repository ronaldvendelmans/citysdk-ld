require 'sequel/model'
require 'sequel/plugins/serialization'
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
    g = h
    while(a.length > 1 )
      aa = a.shift.to_sym
      g[aa] = {} if g[aa].nil?
      g = g[aa]
    end
    g[a[0].to_sym] = v
    h
  end

  def self.nest(h)
    xtra = {}
    h.each_key do |k|
      i = k.to_s.index(KEY_SEPARATOR)
      if i
        a = k.to_s.split(KEY_SEPARATOR)
        atonestedh(a,h[k],xtra)
        h.delete(k)
        h.delete(a) if h[a]
        h = h.merge(xtra)
      end
    end
    h
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
