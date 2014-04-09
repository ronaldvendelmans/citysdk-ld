# encoding: UTF-8

module CitySDKLD
  class Objects < Grape::API

    resource :objects do

      desc 'Return all objects'
      get '/' do
        dataset = Node.dataset
          .geo_bounds(params)
          .name_search(params)
          .modality_search(params)
          .route_members(params)
          .nodedata(params)
          .node_layers(params)
          .do_paginate(params)

        dataset.serialize :nodes, params
      end

      desc 'Return single object'
      get '/:cdk_id' do
        dataset = Node.where(cdk_id: params[:cdk_id])
          .node_layers(params)

        dataset.serialize :node, params
      end

      desc 'Return all layers that contain data of single object'
      get '/:cdk_id/layers' do

      end

      desc 'Return all data on single layer of single object'
      get '/:cdk_id/layers/:layer_name' do

      end

    end

  end
end
