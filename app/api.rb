# encoding: UTF-8

module CitySDKLD
  class API < Grape::API

    # default_format :json

    format :json
    version 'v1', using: :header, vendor: 'citysdk-ld'

    content_type :json, 'application/json'
    formatter :json, lambda { |object, env|
      Serializer.serialize :geojson, object, env
    }

    content_type :jsonld, 'application/ld+json'
    formatter :jsonld, lambda { |object, env|
      Serializer.serialize :jsonld, object, env
    }

    content_type :turtle, 'text/turtle'
    formatter :turtle, lambda { |object, env|
      Serializer.serialize :turtle, object, env
    }

    before do
      params[:url] = env['REQUEST_URI']
    end

    mount ::CitySDKLD::Layers
    mount ::CitySDKLD::Objects
    mount ::CitySDKLD::Owners
    mount ::CitySDKLD::Status

    add_swagger_documentation api_version: 'v1'
  end
end
