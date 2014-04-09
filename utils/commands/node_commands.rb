class CitySDKLD < Sinatra::Base

  module Nodes
    
    def self.process_command?(n,params)
      ['routes','regions', 'routes_start', 'routes_end'].include? params[:cmd]
    end
    
    def self.process_command(n, params)
      cdk_id = params['cdk_id']
      if params[:cmd] == 'routes'        
        dataset = Node.dataset
          .where("members @> ARRAY[cdk_id_to_internal('#{cdk_id}')]") 
          .name_search(params)
          .route_members(params)          
          .nodedata(params)
          .node_layers(params)
          .do_paginate(params)
          
        dataset.serialize(:nodes, params)     
      elsif params[:cmd] == 'routes_start' or params[:cmd] == 'routes_end'
        # Select all routes that start or end in cdk_id, 
        # i.e. cdk_id = members[0] or cdk_id = members[-1]
        #
        # Example:
        #   SELECT * FROM nodes 
        #   WHERE cdk_id_to_internal('n712651044') = members[array_lower(members, 1)]
        
        array_function = :array_lower
        if params[:cmd] == 'routes_end'
          array_function = :array_upper
        end
                    
        dataset = Node.dataset
          .where(Sequel.function(:cdk_id_to_internal, cdk_id) =>  Sequel.pg_array(:members)[Sequel.function(array_function, :members, 1)]) 
          .name_search(params)
          .route_members(params)          
          .nodedata(params)
          .node_layers(params)
          .do_paginate(params)
          
        dataset.serialize(:nodes, params)
      elsif params[:cmd] == 'regions'

        # TODO: hard-coded layer_id of admr = 2! 
        layers = [0,1,2]
        if params.has_key? 'layer'
          layers = Layer.id_from_name(params['layer'].split(','))          
        end
       
        # TODO: also filter on node_data, name etc!
        # TODO: hard-coded layer_id of admr = 2! 
                
        # TODO: let serializer set geom_function
        geom_function = (params[:request_format] == :turtle) ? :ST_AsText : :ST_AsGeoJSON        
        columns = (Node.dataset.columns - [:geom]).map { |column| "nodes__#{column}".to_sym }
 
        #self.select_append(Sequel.function(geom_function, Sequel.function(:COALESCE, Sequel.function(:collect_member_geometries, :members), :geom)).as(:geom))
        
        params['layer'] = '*'
        dataset = Node.dataset
          .join_table(:inner, :nodes, Sequel.function(:ST_Intersects, :nodes__geom, :containing_node__geom), {:table_alias=>:containing_node})
          .where(:containing_node__cdk_id=>cdk_id)
          .where(:nodes__layer_id=>2)
          .select_all(:nodes)
          .eager_graph(:node_data).where(:node_data__layer_id => layers)
          .add_graph_aliases(:geom=>[
            :nodes, :geom, 
            Sequel.function(geom_function, Sequel.function(:COALESCE, Sequel.function(:collect_member_geometries, :members), :geom))
          ])
          .order(Sequel.lit("(data -> 'admn_level')::int")).reverse
        
        dataset.serialize(:nodes, params)

      else 
        CitySDKLD.do_abort(422,"Command #{params[:cmd]} not defined for this node type.")
      end
    end
  end
  
end
