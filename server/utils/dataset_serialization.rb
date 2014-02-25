module Sequel
  
  class Dataset

	  def serialize(type, params)
	    case type
      when :node, :nodes
        nodes = nodes(params).each { |h| Node.make_hash(h, params) }

        if type == :node and nodes.length == 0
          CitySDK_API.do_abort(422,"Node not found: '#{params[:node]}'")
        end

        meta = {
          status: "succes",
          url: params[:url]
        }
        meta.merge! pagination_results(params, get_pagination_data(params), nodes.length)         
        
        Serializer.serialize params[:request_format], :nodes, nodes, [], meta
      when :layer, :layers
      when :message
      when :status
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