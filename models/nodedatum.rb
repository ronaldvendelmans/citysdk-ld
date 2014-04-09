require 'sequel/model'
require 'sequel/plugins/serialization'
require 'set'
require 'json'

require_relative 'node.rb'

class NodeDatum < Sequel::Model
  many_to_one :node
  many_to_one :layer

	plugin :validation_helpers

  KEY_SEPARATOR = ':'

  def self.array_to_nested_hash(a,v,h)
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
        array_to_nested_hash(a,h[k],xtra)
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

  def self.make_hash(cdk_id, h, params)
    newh = {}
    h.each do |nd|

      layer_id = nd[:layer_id]

      name = Layer.name_from_id(layer_id)

      nd.delete(:validity)

      nd.delete(:tags) if nd[:tags].nil?

      if nd[:modalities]
        nd[:modalities] = nd[:modalities].map { |m| Modality.name_from_id(m) }
      else
        nd.delete(:modalities)
      end

      nd.delete(:id)
      nd.delete(:node_id)
      nd.delete(:parent_id)
      nd.delete(:layer_id)
      nd.delete(:node_data_type)
      nd.delete(:created_at)
      nd.delete(:updated_at)

      if Layer.is_webservice?(layer_id) and !params.has_key?('skip_webservice')
        nd[:data] = WebService.load(layer_id, cdk_id, nd[:data])
      end

      nd[:data] = nest(nd[:data].to_hash)
      newh[name] = nd
    end
    newh
  end

end
