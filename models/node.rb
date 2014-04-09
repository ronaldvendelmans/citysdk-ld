class Node < Sequel::Model
  one_to_many :node_data

  NODE_TYPES = ['node', 'route', 'ptstop', 'ptline']

  def get_layer(n)
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

  # TODO: to_hash cannot be used, it seems. Find other name?
  def self.make_hash(h, params)
    h[:layers] = NodeDatum.make_hash h[:cdk_id], h[:node_data], params if h[:node_data]

    h.delete(:members)

    h[:layer] = Layer.name_from_id(h[:layer_id])
    h[:name] = '' if h[:name].nil?
    if h[:geom]
      h[:geom] = h[:geom]
    end

    if h[:modalities]
      h[:modalities] = h[:modalities].map { |m| Modality.name_from_id(m) }
    else
      h.delete(:modalities)
    end

    h.delete(:related) if h[:related].nil?
    #h.delete(:modalities) if (h[:modalities] == [] or h[:modalities].nil?)
    h[:node_type] = NODE_TYPES[h[:node_type]]
    h.delete(:layer_id)
    h.delete(:id)
    h.delete(:node_data)
    h.delete(:created_at)
    h.delete(:updated_at)
    h
  end

end
