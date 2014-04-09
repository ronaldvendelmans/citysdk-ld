module CitySDK_LD
  class API < Grape::API
    #prefix 'api'
    #format :json
    mount ::CitySDK_LD::Ping
    mount ::CitySDK_LD::Entities::API
    
    mount ::CitySDK_LD::Layers
    
    add_swagger_documentation api_version: 'v1'
  end
end