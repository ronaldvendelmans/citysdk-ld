# encoding: UTF-8

module CitySDKLD
  class Users < Grape::API

    resource :users do

      get '/' do

      end

      get "/:user_name" do

      end

    end
  end
end
