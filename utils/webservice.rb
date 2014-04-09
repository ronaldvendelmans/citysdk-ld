class NodeDatum < Sequel::Model

  module WebService
    require 'faraday'
    require 'net/http'
    require 'uri'

    def self.memcached_key(layer_id, cdk_id)
      l = Layer.name_from_id(layer_id)
      return "#{l}!!#{cdk_id}"
    end

    def self.load_from_ws(url,data)
      connection = Faraday.new(:url => url)
      response = connection.post('',data.to_json)
      if(response.status == 200)
        begin
          r = JSON.parse(response.body)
          return r['data']
        rescue Exception => e
          puts e.message
        end
      else
        puts response.body
      end
      return nil
    end

    def self.load(layer_id, cdk_id, hstore)
      key = memcached_key(layer_id, cdk_id)
      data = CitySDKLD.memcached_get(key)
      if data
        return data
      else
        url = Layer.get_webservice_url(layer_id)
        data = load_from_ws(url,hstore)
        if(data)
          CitySDKLD.memcached_set(key, data, Layer.get_data_timeout(layer_id) )
          return data
        end
      end
      hstore
    end

  end
end