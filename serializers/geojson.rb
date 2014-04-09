# encoding: UTF-8

class GeoJSONSerializer < Serializer::Base

  def self.start
    @result = {
      type: "FeatureCollection",
      meta: @meta,
      features: []
    }
  end

  def self.end
    @result.to_json
  end

  def self.nodes
    @data.each do |node|
      feature = {
        type: "Feature",
        properties: {
          cdk_id: node[:cdk_id],
          name: node[:name],
          node_type: node[:node_type],
          layer: node[:layer]
        },
        geometry: node[:geom] ? JSON.parse(node[:geom].round_coordinates(Serializer::PRECISION)) : {}
      }
      feature[:properties][:layers] = node[:layers] if node.has_key? :layers and node[:layers]
      @result[:features] << feature
    end
  end

  def self.layers
    @data.each do |layer|
      feature = {
        type: "Feature",
        properties: {
          name: layer[:name],
          title: layer[:title],
          description: layer[:description],
          category: layer[:category],
          organization: layer[:organization],
          data_sources: layer[:data_sources],
          #realtime: layer[:realtime],
          update_rate: layer[:update_rate],
          webservice: layer[:webservice],
          imported_at: layer[:imported_at],
          owner: layer[:owner].delete_if { |k, v| v.nil? },
          fields: layer[:fields],
          context: layer[:context]
        },
        geometry: layer[:geojson] ? layer[:geojson] : {}
      }
      feature.delete_if { |k, v| v.nil? }
      feature[:properties].delete_if { |k, v| v.nil? }
      @result[:features] << feature
    end
  end

  def self.status
    @result[:features] << {
      type: "Feature",
      properties: @data,
      geometry: @data[:geometry]
    }
  end

end