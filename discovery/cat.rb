$LOAD_PATH.unshift File.dirname(__FILE__)

require 'json'
require 'sinatra'
require 'sinatra/sequel'
require './utils'


configure do | app |
  if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
          database.disconnect if forked
      end
  end
  config = JSON.parse(File.read('./db.json')) 
  app.database = "postgres://#{config['db_user']}:#{config['db_pass']}@#{config['db_host']}/#{config['db_name']}"
end

class Endpoint < Sequel::Model(:endpoints)
end

class Layer < Sequel::Model(:layers)
end


class CSDK_CAT < Sinatra::Base
  
  before do
    # puts JSON.pretty_generate(request.env)
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  after do
  end
  
  get '/update' do
    if request.env['REMOTE_ADDR'] == '127.0.0.1' or request.env['REMOTE_ADDR'] == '195.169.149.23'
      update_all
    end
  end
  
  put '/endpoint'  do
    if request.env['REMOTE_ADDR'] == '127.0.0.1' or request.env['REMOTE_ADDR'] == '195.169.149.23'
      ep = parse_request_json(request)
      ep = Endpoint.new(ep)
      save_object(ep)
      [200,{'Content-Type' => 'application/json'},{:status => 'success'}.to_json]
    end
  end
  
  get '/endpoints'  do
    h = []
    eps = Endpoint.all
    eps.each do |e|
      a = e.to_hash
      a[:api] = 'http://' + e[:api]
      a[:maintainer] = a.delete(:email)
      a.delete(:id)
      h << a
    end
    [200,{'Content-Type' => 'application/json'},{:results => h}.to_json]
  end

  get '/layers/:category' do
    h = []
    layers = Layer.where(Sequel.expr(:category).ilike("#{params['category']}%"))
             .layer_geosearch(params)
             .order(Sequel.function(:ST_Area, :bbox))
    layers.each do |l|
      a = l.to_hash
      a.delete(:bbox)
      a.delete(:id)
      a[:api] = 'http://' + Endpoint.where(:id => a[:endpoint_id]).first[:api]

      a[:sample] = a[:sample_url] ?
        a[:api] + '/' + a[:sample_url]
        :
        a[:api] + '/nodes?per_page=10&layer=' +  a[:name]
      a.delete(:sample_url)
      a[:endpoint] = Endpoint.where(:id => a[:endpoint_id]).first[:name]
      a.delete(:endpoint_id)
      h << a
    end
    [200,{'Content-Type' => 'application/json'},{:results => h}.to_json]
  end
  
end

