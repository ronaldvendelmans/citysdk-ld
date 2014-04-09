module CitySDK_LD
  class API < Grape::API    

    # default_format :json
    
    format :json
    version 'v1', using: :header, vendor: 'citysdk-ld'
    
    content_type :turtle, "text/turtle"
    formatter :turtle, lambda { |object, env| 
      puts object.inspect
      puts env.inspect
      object.to_json 
    }
    
    mount ::CitySDK_LD::Layers
    mount ::CitySDK_LD::Objects
    mount ::CitySDK_LD::Users
    
    add_swagger_documentation api_version: 'v1'
  end
end