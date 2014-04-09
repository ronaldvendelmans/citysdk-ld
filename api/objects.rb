# encoding: UTF-8

module CitySDKLD
  class Objects < Grape::API

    resource :objects do

      # /objects                          All objects
      # /objects/<cdk_id>                 Single object
      # /objects/<cdk_id>/layers          All layers that contain data of single object
      # /objects/<cdk_id>/layers/<layer>  All data on single layer of single object

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

      get "/:cdk_id" do
        dataset = Node.where(cdk_id: params[:cdk_id])
          .node_layers(params)

        dataset.serialize :node, params
      end

    end

  end
end
