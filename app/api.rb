# encoding: UTF-8

module CitySDKLD
  class API < Grape::API

    # default_format :json

    format :json
    version 'v1', using: :header, vendor: 'citysdk-ld'

    content_type :turtle, 'text/turtle'
    formatter :turtle, lambda { |object, env|
      puts object.inspect
      puts env.inspect
      object.to_json
    }

    before do
      params[:url] = env['REQUEST_URI']
    end

    mount ::CitySDKLD::Layers
    mount ::CitySDKLD::Objects
    mount ::CitySDKLD::Users
    mount ::CitySDKLD::Status

    add_swagger_documentation api_version: 'v1'
  end
end
