# encoding: UTF-8

module CitySDKLD
  # Layers resource for Grape REST API
  class Layers < Grape::API
    resource :layers do

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

      get '/:layer_name' do
        layer_id = Layer.id_from_name(params[:layer_name])

        dataset = Layer.where(id: layer_id)
        dataset.serialize :layer, params
      end

    end
  end
end
