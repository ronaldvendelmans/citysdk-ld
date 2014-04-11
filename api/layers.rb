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

      # TODO: get regex from Layer model class
      resource '/:layer_name', requirements: { layer_name: /\w+(\.\w+)*/ } do

        desc 'Return single layer'
        get '/' do
          # TODO: make sure only memcached is accessed - not the database
          layer_id = Layer.id_from_name(params[:layer_name])
          dataset = Layer.where(id: layer_id)
          dataset.serialize :layer, params
        end

        desc 'Return all users associated with single layer'
        get '/users' do
          puts "users"
          {}
        end

        desc 'Return JSON-LD context of single layer'
        get '/@context' do
          # TODO: make sure only memcached is accessed - not the database
          layer_id = Layer.id_from_name(params[:layer_name])
          layer = Layer.get_layer(layer_id)
          {
            type: :@context,
            data:  layer[:@context],
            layers: [],
            meta: []
          }
        end

        resource '/objects' do

          desc 'Return all objects with data on single layer'
          get '/' do
            puts 'Return all objects with data on single layer'
            {}
          end

          desc 'Return metadata of single layer about single object, e.g. the date the data was added/modified, etc.'
          get '/:cdk_id' do
            puts 'vissen Return metadata of single layer about single object, e.g. the date the data was added/modified, etc.'
            {}
          end

        end

        resource '/fields' do

          desc 'Return all fields of single layer'
          get '/fields/' do

          end

          desc 'Return single field of single layer'
          get '/fields/:field_name' do

          end

        end

      end

    end
  end
end
