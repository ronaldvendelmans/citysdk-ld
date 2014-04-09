module CitySDK_LD
  class Layers < Grape::API
    format :json
    version 'v1', using: :header, vendor: 'citysdk-ld'
    
    # default_format :json
    
    content_type :turtle, "text/turtle"
    formatter :turtle, lambda { |object, env| 
      puts object.inspect
      puts env.inspect
      object.to_json 
    }
    
    resource :layers do    
    
    get '/' do      
      # dataset = Node.where(:cdk_id=>'n1767325280')
      #   .node_layers(params)
      #     
      # dataset.serialize :node, params      
      
      dataset = Layer.dataset
        .order(:id)
        .name_search(params)
        .category_search(params)
        .layer_geosearch(params)
        .only_layer_ids(params)
        .do_paginate(params)    

      dataset.serialize :layers, params
    end
 
    
    get "/:layer_name" do 
      
      layer_id = Layer.id_from_text(:layer_name)

      dataset = Layer.where(:id => layer_id)
      dataset.serialize :layer, params
      
      #Post.find(params['id'])
    end

    
    
    end
  end
end