require 'json'

module CitySDK_LD
    
  Sequel.extension :pg_hstore_ops
  Sequel.extension :pg_array_ops

  class App
    def initialize
      @filenames = ['', '.html', 'index.html', '/index.html']
      @rack_static = ::Rack::Static.new(
        lambda { [404, {}, []] },
        root: File.expand_path('../../public', __FILE__),
        urls: ['/']
        )
    
      @config = JSON.parse(File.read('./config.json'),{:symbolize_names => true}) 
      
      @database = Sequel.connect "postgres://#{@config[:db_user]}:#{@config[:db_pass]}@#{@config[:db_host]}/#{@config[:db_name]}"
      
      #@database.logger = Logger.new(STDOUT)

      @database.extension :pg_array
      @database.extension :pg_range
      @database.extension :pg_hstore
      
      Sequel::Model.db.extension(:pagination)
      Sequel::Model.plugin :json_serializer
      
      # TODO: is this right place?
      Dir[File.expand_path('../../models/*.rb', __FILE__)].each { |file| require file }
      Dir[File.expand_path('../../serializers/*.rb', __FILE__)].each { |file| require file }
      Dir[File.expand_path('../../utils/*.rb', __FILE__)].each { |file| require file }
      
      #
      # sinatraApp.database = 
      # 
      # #sinatraApp.database.logger = Logger.new(STDOUT)
      # 
      # sinatraApp.database.extension :pg_array
      # sinatraApp.database.extension :pg_range
      # sinatraApp.database.extension :pg_hstore
      # 
      # require File.dirname(__FILE__) + '/api_read.rb'
      # require File.dirname(__FILE__) + '/api_write.rb'
      # require File.dirname(__FILE__) + '/api_delete.rb'
      # 
      # Dir[File.dirname(__FILE__) + '/utils/*.rb'].each {|file| require file }
      # Dir[File.dirname(__FILE__) + '/utils/match/*.rb'].each {|file| require file }
      # Dir[File.dirname(__FILE__) + '/utils/commands/*.rb'].each {|file| require file }
      # Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
      # Dir[File.dirname(__FILE__) + '/serializers/*.rb'].each {|file| require file }
        
        
        
        
        
        
    end

    def self.instance
      @instance ||= Rack::Builder.new do
        use Rack::Cors do
          allow do
            origins '*'
            resource '*', headers: :any, methods: :get
          end
        end

        run CitySDK_LD::App.new
      end.to_app
    end

    def call(env)
      # api
      response = CitySDK_LD::API.call(env)

      # Check if the App wants us to pass the response along to others
      if response[1]['X-Cascade'] == 'pass'
        # static files
        request_path = env['PATH_INFO']
        @filenames.each do |path|
          response = @rack_static.call(env.merge('PATH_INFO' => request_path + path))
          return response if response[0] != 404
        end
      end

      # Serve error pages or respond with API response
      case response[0]
      when 404, 500
        content = @rack_static.call(env.merge('PATH_INFO' => "/errors/#{response[0]}.html"))
        [response[0], content[1], content[2]]
      else
        response
      end
    end
  end
end