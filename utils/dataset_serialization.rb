module Sequel
  
  class Dataset

	  def serialize(type, params)
      # TODO: move to api.rb, add meta as parameter
      meta = {
        status: "succes",
        url: params[:url]
      }
	    case type
      when :node, :nodes
        
        # Use layers hash to get data of used layer, to be used in json-ld/turtle serialization
        layers = {}
        layer_ids = []
        nodes = nodes(params).each do |h|          
          # Add layer_id of all data to layers array
          h[:node_data].each { |d| layer_ids << d[:layer_id] } if h[:node_data]
          Node.make_hash(h, params)
        end
        layer_ids.uniq.each do |layer_id|
          layer = Layer.get_layer layer_id
          layers[layer[:name]] = layer
        end        
              
        if type == :node and nodes.length == 0
          CitySDK_LD.do_abort(422,"Node not found: '#{params[:node]}'")
        end
        
        meta.merge! pagination_results(params, get_pagination_data(params), nodes.length)         
        
        Serializer.serialize params[:request_format], :nodes, nodes, layers, meta
      when :layer, :layers
        
        # Postgres result in self.all only contains layer_ids
        # Get layers data from internal layers hash
        
        layer_ids = self.all.map { |a| a.values[:id] }

        if type == :layer and layer_ids.length == 0
          CitySDK_LD.do_abort(422,"Layer not found: '#{params[:layer]}'")
        end

        layers = layer_ids.map { |layer_id| Layer.get_layer layer_id }        
        
        meta.merge! pagination_results(params, get_pagination_data(params), layers.length)         
         
        Serializer.serialize params[:request_format], :layers, layers, [], meta        
      end
	  end

	  def pagination_results(params, pagination_data, length)
	    if pagination_data
	      if length < pagination_data[:page_size] 
	        {
	          :pages => pagination_data[:current_page],
	          :per_page => pagination_data[:page_size],
	          :record_count => pagination_data[:page_size] * (pagination_data[:current_page] - 1) + length,
	          :next_page => -1, 
	        } 
        elsif params.has_key? 'count'
	        {
	          :pages => pagination_data[:page_count],
	          :per_page => pagination_data[:page_size],
	          :record_count => pagination_data[:pagination_record_count],
	          :next_page => pagination_data[:next_page] || -1, 
	        }
        else
          {
	          :per_page => pagination_data[:page_size],
	          :next_page => pagination_data[:next_page] || -1,             
          }
	      end
	    else # pagination_data == nil
	      {}
	    end
	  end
	
	end
end