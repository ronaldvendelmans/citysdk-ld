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

      # TODO: get regex from Object model class
      resource '/:cdk_id', requirements: { cdk_id: /\w+(\.\w+)*/ } do

        desc 'Return single object'
        get '/' do
          dataset = Node.where(cdk_id: params[:cdk_id])
            .node_layers(params)

          dataset.serialize :node, params
        end

        resource '/layers' do

          desc 'Return all layers that contain data of single object'
          get '/' do

          end

          desc 'Return all data on single layer of single object'
          get '/:layer_name', requirements: { layer_name: /\w+(\.\w+)*/ } do

          end

        end

      end

    end

  end
end
