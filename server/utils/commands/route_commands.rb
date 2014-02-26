class CitySDK_API < Sinatra::Base
  
  module Routes
    
    def self.process_command?(n,params)
      ['nodes','start_end','routes'].include? params[:cmd]
    end
    
    def self.process_command(n, params)
      cdk_id = params['cdk_id']
      if params[:cmd] == 'nodes'
        dataset = Node.dataset
          .where(:nodes__id => Sequel.function(:ANY, Sequel.function(:get_members, cdk_id)))
          .nodedata(params)
          .node_layers(params)
          .do_paginate(params)
          .order(Sequel.function(:idx, Sequel.function(:get_members, cdk_id), :nodes__id))

        dataset.serialize(:nodes, params)
      elsif params[:cmd] == 'start_end'
        dataset = Node.dataset
          .where(:nodes__id => Sequel.function(:ANY, Sequel.function(:get_start_end, cdk_id)))          
          .nodedata(params)
          .node_layers(params)

        dataset.serialize(:nodes, params)
      elsif params[:cmd] == 'routes'

        sql_where = <<-SQL
          cdk_id = ANY(ARRAY(
            SELECT nodes.cdk_id FROM nodes 
            INNER JOIN nodes AS route_nodes ON (route_nodes.members && nodes.members)
            WHERE route_nodes.cdk_id = ?)) AND
            nodes.cdk_id != ?
        SQL

        dataset = Node.dataset
          .where(sql_where.lit(cdk_id, cdk_id))
          .name_search(params)
          .route_members(params)
          .nodedata(params)
          .node_layers(params)
          .do_paginate(params)
          
        dataset.serialize(:nodes, params)
      else 
        CitySDK_API.do_abort(422,"Command #{params[:cmd]} not defined for this node type.")
      end
    end
  end
  
end
