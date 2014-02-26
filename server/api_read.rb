class CitySDK_API < Sinatra::Base
  
  get '/' do    
    kv8  = CitySDK_API::memcache_get('kv8daemon');
    divv = CitySDK_API::memcache_get('divvdaemon');
    @do_cache = false
    
    # TODO: refactor daemon system, let daemons register themselves
    # TODO: get version from somewhere else!  
    # TODO: get geometry from somewhere else!  
    status = {
      name: "citysdk-ld",
      description: "CitySDK Linked Data API - documentation @ http://citysdk.waag.org",
      version: "0.9",
      config: Config,
      geometry: {
        type: "Polygon",
        coordinates: [
          [
            [3.284912,50.715591],
            [3.284912,53.742213],
            [7.327880,53.742213],
            [7.327880,50.715591],
            [3.284912,50.715591]
          ]
        ]
      },
      daemons: {
        "kv8" => kv8 ? "alive, #{kv8}" : "dead",
        "divv" => divv ? "alive, last timestamp: #{divv}" : "dead",
      }
    }
    
    meta = {
      status: "succes",
      url: params[:url]
    }
    
    Serializer.serialize params[:request_format], :status, status, [], meta
  end

  get '/get_session' do
    @do_cache = false
    st,sess = Owner.login(params[:e],params[:p])
    { :status => st,
      :results => [sess]
    }.to_json
  end

  get '/release_session' do
    @do_cache = false
    if Owner.validSession(request.env['HTTP_X_AUTH'])
      Owner.release_session(request.env['HTTP_X_AUTH'])
      { :status => 'success' }.to_json
    else
      CitySDK_API.do_abort(401,"Not Authorized")
    end
  end

  ###### Data URL handlers:

  get '/regions/?' do
    path_regions
  end
  
  get '/layers/reload__' do
    @do_cache = false
    Layer.getLayerHashes
    { :status => 'success' }.to_json
  end

  get '/layers/?' do
    # layer_geometry also sets proper PostGIS geom 
    # serialization - always call layer_geometry
    dataset = Layer.dataset
      .name_search(params)
      .category_search(params)
      .layer_geometry(params)
      .layer_geosearch(params)
      .do_paginate(params)    

    dataset.serialize :layers, params
  end
  
  get '/layer/:name/?' do |name|
    layer_id = Layer.idFromText(name)

    Node.serializeStart(params,request)
    Layer[layer_id].serialize(params,request)
    Node.serializeEnd(params, request)
  end

  get '/nodes/?' do
    path_cdk_nodes
  end

  get '/routes/?' do
    path_cdk_nodes(1)
  end

  get '/ptstops/?' do
    path_cdk_nodes(2)
  end

  get '/ptlines/?' do
    path_cdk_nodes(3)
  end

  get '/:within/nodes/?' do
    path_cdk_nodes
  end

  get '/:within/routes/?' do
    path_cdk_nodes(1)
  end

  get '/:within/ptstops/?' do
    path_cdk_nodes(2)
  end

  get '/:within/ptlines/?' do
    path_cdk_nodes(3)
  end

  get '/:within/regions/?' do
    path_regions
  end

  
  get '/:cdk_id/select/:cmd/?' do
    n = Node.where(:cdk_id=>params[:cdk_id]).first    
    if n.nil?
      CitySDK_API.do_abort(422,"Node not found: #{params[:cdk_id]}")
    end
  
    code = 0, h = {}
    case n.node_type
      when 0 # nodes
        Nodes.processCommand(n,params,request)
      when 1 # routes        
        Routes.processCommand(n,params,request)
      when 2 # ptstops
        if( Nodes.processCommand?(n,params) ) 
          Nodes.processCommand(n,params,request)      
        else
          PublicTransport.processStop(n,params,request)
        end
      when 3 # ptlines
        if( Routes.processCommand?(n,params) ) 
          Routes.processCommand(n,params,request)    
        else
          PublicTransport.processLine(n,params,request)
        end
      else
        CitySDK_API.do_abort(422,"Unknown command for #{params[:cdk_id]} ")
    end
  end

  get '/:node/:layer/?' do
    if 0 == Node.where(:cdk_id=>params[:node]).count
      CitySDK_API.do_abort(422,"Node not found: '#{params[:node]}'")
    end
    if 0 == Layer.where(:name=>params[:layer]).count
      CitySDK_API.do_abort(422,"Layer not found: '#{params[:layer]}'")
    end
    n  = Node.where(:cdk_id=>params[:node]).first
    nd = NodeDatum.where(:layer_id => Layer.idFromText(params[:layer])).where(:node_id => n.id).first
    
    case params[:request_format]
    when 'application/json'
      { :status => 'success', 
        :url => request.url,
        :results => [NodeDatum.serialize(params[:node],[nd.values],params)]
      }.to_json 
    when 'text/turtle'
      Node.serializeStart(params,request)
      t,d = NodeDatum.turtelize(params[:node],[nd.values],params)
      [Node.prefixes.join("\n"),Node.layerProps(params).join("\n"),d.join("\n")].join("\n")
    end
    
  end

  get '/:node/?' do
    dataset = Node.where(:cdk_id=>params[:node])
      .node_layers(params)
    
    dataset.serialize :node, params    
  end
  
  # keep it dry
  def path_cdk_nodes(node_type=nil)
    begin
      dataset = 
        if node_type
          params["node_type"] = node_type
          Node.dataset
            .where(:node_type=>node_type)
            .geo_bounds(params)
            .name_search(params)
            .modality_search(params)
            .route_members(params)
            .nodedata(params)
            .node_layers(params)
            .do_paginate(params)
        else
          Node.dataset
            .geo_bounds(params)
            .name_search(params)
            .modality_search(params)
            .route_members(params)
            .nodedata(params)
            .node_layers(params)
            .do_paginate(params)
        end      
    
      dataset.serialize(:nodes, params)
    rescue Exception => e
      CitySDK_API.do_abort(500,"Server error (#{e.message}, \n #{e.backtrace.join('\n')}.")
    end

  end
  
  def path_regions
    begin 
      # TODO: hard-coded layer_id of admr = 2! 
      pgn = Node.dataset.where(:nodes__layer_id=>2)
        .geo_bounds(params)
        .name_search(params)
        .nodedata(params)
        .node_layers(params)
        .do_paginate(params)

      CitySDK_API.nodes_results(pgn, params, request)
    rescue Exception => e
      CitySDK_API.do_abort(500,"Server error (#{e.message}, \n #{e.backtrace.join('\n')}.")
    end
  end

end