# encoding: UTF-8

module CitySDKLD
  class Owners < Grape::API

    resource :owners do

      desc 'Return all owners'
      get '/' do

      end

      desc 'Return single owner'
      get '/:owner_name' do

      end

      desc 'Return all layers belonging to single owner'
      get '/:owner_name/layers' do

      end

    end
  end
end
