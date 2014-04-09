# encoding: UTF-8

module CitySDKLD
  class Users < Grape::API

    resource :users do

      desc 'Return all users'
      get '/' do

      end

      desc 'Return single user'
      get '/:user_name' do

      end

      desc 'Return all layers belonging to single user'
      get '/:user_name/layers' do

      end

    end
  end
end
