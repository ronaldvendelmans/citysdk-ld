# encoding: UTF-8

module CitySDKLD
  # Layers resource for Grape REST API
  class Layers < Grape::API
    resource :layers do

      desc 'Return all layers'
      get '/' do
        dataset = Layer.dataset
          .order(:id)
          .name_search(params)
          .category_search(params)
          .layer_geosearch(params)
          .only_layer_ids(params)
          .do_paginate(params)

        dataset.serialize :layers, params
      end

      desc 'Return single layer'
      get '/:layer_name' do
        layer_id = Layer.id_from_name(params[:layer_name])

        dataset = Layer.where(id: layer_id)
        dataset.serialize :layer, params
      end

      desc 'Return all objects with data on single layer'
      get '/layers/:layer_name/objects' do

      end

      Return metadata of single layer about single object, e.g. the date the data was added/modified, etc.
      get '/layers/:layer_name/objects/:cdk_id' do


      desc 'Return all users associated with single layer'
      get '/layers/:layer_name/users/' do

      end

      desc 'Return all fields of single layer'
      get '/layers/:layer_name/fields/' do

      end

      desc 'Return single field of single layer'
      get '/layers/:layer_name/fields/:field_name' do

      end

    end
  end
end
