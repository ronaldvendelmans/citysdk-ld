class Node < Sequel::Model
  one_to_many :node_data
  
  NODE_TYPES = ['node', 'route', 'ptstop', 'ptline'] 
  
  # There's no need to output coordinates with 
  # infinite decimal places.
  # We will round all coordinates to PRECISION
  # places with the round_coordinates function.
  #
  # From: http://stackoverflow.com/questions/7167604/how-accurately-should-i-store-latitude-and-longitude  
  #
  # decimal  degrees    distance
  # places
  # -------------------------------  
  # 0        1.0        111 km
  # 1        0.1        11.1 km
  # 2        0.01       1.11 km
  # 3        0.001      111 m
  # 4        0.0001     11.1 m
  # 5        0.00001    1.11 m
  # 6        0.000001   0.111 m
  # 7        0.0000001  1.11 cm
  # 8        0.00000001 1.11 mm
  PRECISION = 6 

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

  # TODO: to_hash cannot be used, it seems. Find other name?
  def self.make_hash(h, params)    
    h[:layers] = NodeDatum.make_hash h[:cdk_id], h[:node_data], params if h[:node_data]

    h.delete(:members)

    h[:layer] = Layer.nameFromId(h[:layer_id])
    h[:name] = '' if h[:name].nil?
    if h[:geom]
      h[:geom] = JSON.parse(h[:geom].round_coordinates(PRECISION))
    end
    
    if h[:modalities]
      h[:modalities] = h[:modalities].map { |m| Modality.NameFromId(m) }
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
