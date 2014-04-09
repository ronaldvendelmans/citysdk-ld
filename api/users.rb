# encoding: UTF-8

module CitySDKLD
  class Users < Grape::API

    resource :users do

      # /users                            All users
      # /users/<user>                     Single user
      # /users/<user>/layers              All layers belonging to single user

      get '/' do

      end

      get "/:user_name" do

      end

    end
  end
end
