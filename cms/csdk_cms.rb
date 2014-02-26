$LOAD_PATH.unshift File.dirname(__FILE__)

require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/session'
require 'json'
require 'open-uri'
require 'citysdk'
require 'base64'

configure do | app |
  if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
          if forked
              # We're in smart spawning mode.
              database.disconnect
          else
              # We're in direct spawning mode. We don't need to do anything.
          end
      end
  end

  $config = JSON.parse(File.read('./config.json')) 
  app.database = "postgres://#{$config['db_user']}:#{$config['db_pass']}@#{$config['db_host']}/#{$config['db_name']}"
  app.database.extension :pg_array
  app.database.extension :pg_range


  # app.database.logger = Logger.new(STDOUT)

  Dir[File.dirname(__FILE__) + '/utils/*.rb'].each {|file| require file }
  Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

end

enable :sessions

class CSDK_CMS < Sinatra::Base
  
  set :views, Proc.new { File.join(root, "../views") }  

  # puts settings.root

  use Rack::MethodOverride
  register Sinatra::Session
  set :session_expire, 60 * 60 * 24
  set :session_fail, '/login'
  set :session_secret, '09989dhlkjh7892%$#%2kljd'
  

  def self.do_abort(code,message)
    throw(:halt, [code, {'Content-Type' => 'text/plain'}, message])
  end

  before do
    
    @apiServer = $config['ep_api_url'].gsub('http://','')
    @sampleUrl = $config['ep_info_url'] + "/map#http://#{@apiServer}/"

    @oid = session? ? session[:oid] : nil
    # puts "request: #{request.env['PATH_INFO']}"
  end
  
  after do
  end
  
  # TODO: no camel casing! not here and not nowhere!!!!
  def get_layers
    @layerSelect = Layer.selectTag()
    @selected = params[:category] || 'administrative'
    if @selected != 'all'
      ds = Layer.where(Sequel.like(:category, "#{@selected}%"))
    else
      ds = Layer
    end
    if @oid and @oid != 0
      ds = ds.where(:owner_id => @oid)
    end
    @layers = ds.order(:name).all
  end

  get '/' do
    get_layers
    erb :layers, :layout => @nolayout ? false : true
  end
  
  get '/layers' do
    get_layers
    erb :layers, :layout => @nolayout ? false : true
  end

  get '/login' do
    if session?
      redirect '/'
    else
      erb :login
    end
  end
  
  get '/get_layer_keys/:layer' do |ln|
    l = Layer.where(:name=>ln).first
    if(l)
      keys = Sequel::Model.db.fetch("select keys_for_layer(#{l.id})").all
      api = CitySDK::API.new(@apiServer)
      ml = api.get("/nodes?layer=#{ln}&per_page=1")
      if ml[:status] == 'success' and  ml[:results][0]
        h = ml[:results][0][:layers][ln.to_sym][:data]
        h.each_key do |k|
          puts k
          keys[0][:keys_for_layer] << k.to_s
        end
      end
      return keys[0][:keys_for_layer].uniq.to_json
    else
      return '{}'
    end
  end
  
  get '/get_layer_stats/:layer' do |l|
    l = Layer.where(:name=>l).first
    @lstatus = l.import_status || '-'
    @ndata   = NodeDatum.where(:layer_id => l.id).count
    @ndataua = NodeDatum.select(:updated_at).where(:layer_id => l.id).order(:updated_at).reverse.limit(1).all
    @ndataua = ( @ndataua and @ndataua[0] ) ? @ndataua[0][:updated_at] : '-'
    @nodes   = Node.where(:layer_id => l.id).count
    @delcommand = "delUrl('/layer/" + l.id.to_s + "',null,$('#stats'))"
    erb :stats, :layout => false
  end
  
  get '/logout' do
    session_end!
    redirect '/'
  end
  
  post '/login' do
    oid,token = Owner.login(params[:email],params[:password])
    session_start!
    session[:auth_key] = token
    session[:oid] = oid
    
    session[:e] = params[:email]
    session[:p] = params[:password]
    
    redirect '/'
  end
  
  
  get '/owners' do 
    if Owner.valid_session(session[:auth_key])
      if( @oid == 0)
        @owners = Owner.all
        erb :owners
      else
        @errorContext = "Not authorised!"
        erb :gen_error
        return
      end
    else
      redirect '/'
    end
  end

  post '/profile/create' do 
    if Owner.valid_session(session[:auth_key]) and (@oid == 0)
      @owner = Owner.new
      @owner.email = params['email']
      @owner.name = params['email'].split('@')[0]
      @owner.www = params['www']
      @owner.organization = params['organization']
      @owner.domains = params['domains']
      if @owner.valid? and @owner.validatePW(params['password'],params['passwordc'])
        @owner.save
        @owner.createPW(params['password']) if (params['password'] && !params['password'].empty?)
      else
        erb :edit_profile
        return
      end
    else
      CSDK_CMS.do_abort(401,"not authorized")
    end
    redirect '/owners'
  end

  get '/profile/new' do 
    if Owner.valid_session(session[:auth_key]) and (@oid == 0)
      @owner = Owner.new
    else
      CSDK_CMS.do_abort(401,"not authorized")
    end
    erb :edit_profile
  end

  get '/profile/:o_id' do |o|
    if Owner.valid_session(session[:auth_key])
      if( @oid == 0 or (o.to_i == @oid))
        @owner = Owner[o]
        erb :edit_profile
      else
        CSDK_CMS.do_abort(401,"not authorized")
      end
    else
      redirect '/'
    end
  end
  
  post '/profile/:o_id' do |o|
    if Owner.valid_session(session[:auth_key])
      if( @oid == 0 or (o.to_i == @oid))
        @owner = Owner[o]
        @owner.email = params['email']
        @owner.www = params['www']
        @owner.organization = params['organization']
        @owner.domains = params['domains']  if params['domains']
        if @owner.valid? and @owner.validatePW(params['password'],params['passwordc'])
          @owner.save
          @owner.createPW(params['password']) if (params['password'] && !params['password'].empty?)
          redirect '/'
        else
          erb :edit_profile
        end
      else
        CSDK_CMS.do_abort(401,"not authorized")
      end
    end
  end
  
  
  get '/layer/:layer_id/data' do |l|
    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        @period = @layer.period_select()
        @props = {}
        LayerProperty.where(:layer_id => @layer.id).each do |p|
          @props[p.key] = p.serialize
        end
        @langSelect  = Layer.languageSelect
        @ptypeSelect = Layer.propertyTypeSelect
        @lType = @layer.rdf_type_uri
        @epSelect,@eprops = Layer.epSelect
        @props = @props.to_json

        if params[:nolayout]
          erb :layer_data, :layout => false
        else
          erb :layer_data
        end
      else
        CSDK_CMS.do_abort(401,"not authorized")
      end
    else
      redirect '/'
    end
  end
  
  post '/layer/:layer_id/ldprops' do |l|
    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        request.body.rewind 
        data = JSON.parse(request.body.read, {:symbolize_names => true})
        
        @layer.update(:rdf_type_uri=>data[:type])
        data = data[:props]

        data.each_key do |k|
          dk = data[k]
          dk[:unit] = "csdk:unit#{dk[:unit]}" if dk[:unit] != '' and dk[:unit] !~ /^csdk:unit/
          p = LayerProperty.where(:layer_id => l, :key => k.to_s).first
          p = LayerProperty.new({:layer_id => l, :key => k.to_s}) if p.nil?
          p.type  = dk[:type]
          p.unit  = p.type =~ /^xsd:(integer|float)/ ? dk[:unit] : ''
          p.lang  = dk[:lang]
          p.descr = dk[:descr]
          p.eqprop = dk[:eqprop]
          if !p.save
            return [422,{},"error saving property data."]
          end
        end
      end
    end
  end
  
  post '/layer/:layer_id/webservice' do |l|
    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        @layer.webservice = params['wsurl']
        @layer.update_rate = params['update_rate']
        if !@layer.valid? 
          @categories = @layer.cat_select
          redirect "/layer/#{l}/data"
        else
          @layer.save
          redirect "/layer/#{l}/data"
        end
      end
    end
  end
  
  post '/layer/:layer_id/periodic' do |l|
    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        @layer.import_url = params['update_url']
        @layer.import_period = params['period']
        if !@layer.valid? or @layer.import_config.nil?
          @categories = @layer.cat_select
          redirect "/layer/#{l}/data"
        else
          @layer.save
          redirect "/layer/#{l}/data"
        end
      end
    end
  end


  get '/layer/:layer_id/edit' do |l|
    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        @layer.data_sources = [] if @layer.data_sources.nil?
        @categories = @layer.cat_select
        @webservice = @layer.webservice and @layer.webservice != ''
        erb :edit_layer
      else
        CSDK_CMS.do_abort(401,"not authorized")
      end
    else
      redirect '/'
    end
  end
  
  
  get '/prefixes' do
    if Owner.valid_session(session[:auth_key])
      if params[:prefix] and params[:name] and params[:uri]
        if params[:prefix][-1] != ':'
          params[:prefix] = params[:prefix] + ':'
        end
        pr = LDPrefix.new( {
          :prefix => params[:prefix],
          :name => params[:name],
          :url => params[:uri],
          :owner_id => @oid
        })
        pr.save
      end
      
      @prefixes = LDPrefix.order(:name).all
      erb :prefixz, :layout => false
    else
      redirect '/'
    end
  end
  
  delete '/prefix/:pr' do |p|
    if Owner.valid_session(session[:auth_key])
      LDPrefix.where({:owner_id=>@oid, :prefix=>p}).delete
    end
    @prefixes = LDPrefix.order(:name).all
    erb :prefixz, :layout => false
  end
  
  delete '/layer/:layer_id' do |l|

    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        url = "/layer/#{@layer.name}"
        par = []
        params.each_key do |k|
          par << "#{k}=#{params[k]}"
        end
        url += "?" + par.join("&") if par.length > 0
        begin
          api = CitySDK::API.new(@apiServer)
          api.authenticate(session[:e],session[:p]) do
            api.delete(url)
          end
        rescue Exception => e
          @errorContext = "delete layer #{@layer.name}:"
          @errorMessage = e.message
          puts "deleting content of #{@layer.name}, error: #{e.message}\n #{e.backtrace}"
          return "deleting content of #{@layer.name}, error: #{e.message}" + @errorMessage
        end
      end
    end
    get_layers
    redirect "/"
    # params[:nolayout] = true
    # redirect "/layer/#{@layer.id}/data?nolayout"
  end

  get '/layer/new' do
    if Owner.valid_session(session[:auth_key])
      @owner = Owner[@oid]
      if @oid != 0 
        domains = @owner.domains.split(',')
        if( domains.length > 1 )
          @prefix  = "<select name='prefix'> "
          domains.uniq.each do |p|
            @prefix += "<option>#{p}</option>"
          end
          @prefix += "</select>"
        else
          @prefix = domains[0]
        end
      end
      @layer = Layer.new
      @layer.data_sources = []
      @layer.update_rate = 3600
      @layer.organization = @owner.organization
      @categories = @layer.cat_select
      @webservice = false
      erb :new_layer
    else
      CSDK_CMS.do_abort(401,"not authorized")
    end
  end
  
  post '/layer/create' do
    if Owner.valid_session(session[:auth_key])
      
      puts JSON.pretty_generate(params)
      
      @layer = Layer.new
      @layer.owner_id = @oid
  
      if( params['prefix'] && params['prefix'] != '' )
        @layer.name = params['prefix'] + '.' + params['name']
      elsif (params['prefixc']  && params['prefixc'] != '' )
        @layer.name = params['prefixc'] + '.' + params['name']
      else
        @layer.name = params['name']
      end
  
      params['validity_from'] = Time.now.strftime('%Y-%m-%d') if params['validity_from'].nil?
      params['validity_to'] = Time.now.strftime('%Y-%m-%d') if params['validity_to'].nil?
  
      @layer.description = params['description']
      @layer.update_rate = params['update_rate'].to_i
      @layer.validity = "[#{params['validity_from']}, #{params['validity_to']}]"
      @layer.realtime = params['realtime'] ? true : false;
      @layer.data_sources = []
      @layer.data_sources << params["data_sources_x"] if params["data_sources_x"] && params["data_sources_x"] != ''
      @layer.organization = params['organization']
      @layer.category = params['catprefix'] + '.' + params['category']
      @layer.webservice = params['wsurl']
      @layer.update_rate = params['update_rate']
  
      if !@layer.valid? 
        @prefix = params['prefixc']
        @layer.name = params['name']
        @categories = @layer.cat_select
        erb :new_layer
      else
        # api = CitySDK::API.new(@apiServer)
        # api.authenticate(session[:e],session[:p]) do
        #   begin
        #     d = { :data => @layer.to_hash.to_json }
        #     puts JSON.pretty_generate(d)
        #     api.put('/layers',d)
        #   rescue => e
        #     puts e.message
        #   end
        # end
        @layer.save
        get_layers
        erb :layers
      end
    end
  end
  
  post '/layer/edit/:layer_id' do |l|
    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        @layer.description = params['description']
        params['validity_from'] = Time.now.strftime('%Y-%m-%d') if params['validity_from'].nil?
        params['validity_to'] = Time.now.strftime('%Y-%m-%d') if params['validity_to'].nil?
        if( params['realtime'] )
          @layer.realtime = true;
          @layer.update_rate = params['update_rate'].to_i
        else
          @layer.realtime = false;
          @layer.validity = "[#{params['validity_from']}, #{params['validity_to']}]"
        end
        ds = []; i = 0;
        while params["data_sources"][i.to_s]
          if params["data_sources"][i.to_s] != ''
            ds << params["data_sources"][i.to_s] 
          end
          i += 1
        end if params["data_sources"]
        ds << params["data_sources_x"] if params["data_sources_x"] && params["data_sources_x"] != ''
        @layer.data_sources = ds
        @layer.organization = params['organization']
        @layer.category = params['catprefix'] + '.' + params['category']
        
        @layer.webservice = params['wsurl']
        @layer.update_rate = params['update_rate']
        
        @layer.sample_url = params['sample_url'] if params['sample_url'] and params['sample_url'] != ''
        
        
        if !@layer.valid? 
          @categories = @layer.cat_select
          erb :edit_layer
        else
          @layer.save
          api = CitySDK::API.new(@apiServer)
          api.get('/layers/reload__')
          redirect '/'
        end
      else
        CSDK_CMS.do_abort(401,"not authorized")
      end
    else
      redirect '/'
    end
  end
  
  
  post '/layer/:layer_id/loadcsv' do |l|
    
    if Owner.valid_session(session[:auth_key])
      @layer = Layer[l]
      if(@layer && (@oid == @layer.owner_id) or @oid==0)
        p = params['0'] || params['csv']
        @original_file = p[:filename]

        if p && p[:tempfile] 
          @layerSelect = Layer.selectTag()
          begin
            return parseCSV(p[:tempfile], @layer.name)
          rescue => e
            return [422,{},e.message]
          end
        end
      else
        CSDK_CMS.do_abort(401,"not authorized")
      end
    end
  end
  
  get '/fupl/:layer' do |layer|
    @layer = Layer[layer]
    erb :file_upl, :layout => false
  end
  
  
  post '/csvheader' do
    
    if params['add']

      parameters = JSON.parse(Base64.decode64(params['parameters']),{:symbolize_names => true})

      # puts "csvheader parameters: #{parameters}"
      #     
      # puts ""
      #     
      params.delete('parameters')

      # puts "csvheader params: #{params}"
      #     
      # puts ""
      #     
      parameters = parameters.merge(params)
      # 
      # puts "csvheader merged: #{parameters}"
      # 

      parameters.each do |k,v|
        parameters.delete(k) if v =~ /^<no\s+/
      end
      
      parameters[:host] = @apiServer
      parameters[:email] = session[:e]
      parameters[:passw] = session[:p]

      puts "ruby utils/import_file.rb '#{parameters.to_json}' >> log/import.log &"
      system "ruby utils/import_file.rb '#{parameters.to_json}' >> log/import.log &"
      
      
      parameters.delete(:email)
      parameters.delete(:passw)
      parameters.delete(:file_path)
      parameters.delete(:originalfile)
      
      api = CitySDK::API.new(@apiServer)
      puts JSON.pretty_generate(parameters)
      
      api.authenticate(session[:e],session[:p]) do
        begin
          d = { :data => Base64.encode64(parameters.to_json) }
          api.put("/layer/#{parameters[:layername]}/config",d)
        rescue => e
          puts e.message
        end
      end
      
      redirect "/get_layer_stats/#{parameters[:layername]}"

    else
      puts JSON.pretty_generate(params)
      a = matchCSV(params)
      begin 
        a = JSON.pretty_generate(a)
      rescue
      end
      return [200,{},"<hr/><pre>" + a + "</pre>"]

    end
  end
  
end
