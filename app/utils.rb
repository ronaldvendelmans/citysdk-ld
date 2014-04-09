require 'set'

module CitySDK_LD
  
  ##########################################################################################
  # RGeo
  ##########################################################################################
    
  # @@rgeo_factory = RGeo::Geographic.simple_mercator_factory(
  #   :wkb_parser => {:support_ewkb => true}, 
  #   :wkb_generator => {:hex_format => true, :emit_ewkb_srid => true}
  # )
  # 
  # @@wkb_generator = RGeo::WKRep::WKBGenerator.new({
  #   :type_format => :ewkb,
  #   :hex_format => true,
  #   :emit_ewkb_srid => true 
  # })  
  # 
  # def self.rgeo_factory
  #   @@rgeo_factory
  # end
  # 
  # def self.wkb_generator
  #   @@wkb_generator
  # end
    
  ##########################################################################################
  # memcached utilities
  ##########################################################################################
  
  MEMCACHED_NAMESPACE = 'citysdk-ld::'
  
  # To flush local instance of memcached:
  #   echo 'flush_all' | nc localhost 11211
  
  def self.memcached_new
    @@memcache = Dalli::Client.new('localhost:11211')
  end
  
  @@memcache = Dalli::Client.new('localhost:11211')

  def self.memcached_get(key)
    begin
      return @@memcache.get(MEMCACHED_NAMESPACE + key)
    rescue
      begin
        @@memcache = Dalli::Client.new('localhost:11211')
      rescue
        $stderr.puts "Failed connecting to memcache: #{e.message}\n\n"
        @@memcache = nil
      end
    end
  end
  
  def self.memcached_set(key, value, ttl=300)
    begin      
      return @@memcache.set(MEMCACHED_NAMESPACE + key, value, ttl)
    rescue
      begin
        @@memcache = Dalli::Client.new('localhost:11211')
      rescue
        $stderr.puts "Failed connecting to memcache: #{e.message}\n\n"
        @@memcache = nil
      end
    end
  end
  
  ##########################################################################################
  # cdk_id generation
  ##########################################################################################
  
  # Create alphanumeric hashes, 22 characters long
  # base62 = numbers + lower case + upper case = 10 + 26 + 26 = 62
  # Example hash: 22pOqosrbX0KF6zCQiPj49
  def self.md5_base62(s)
    Digest::MD5.hexdigest(s).to_i(16).base62_encode
  end
  
  def self.generate_cdk_id_from_name(layer, text)
    # Normalize text:
    #  downcase, strip,
    #  normalize (é = e, ü = u), 
    #  remove ', ", `,
    #  replace sequences of non-word characters by '.',
    #  Remove leading and trailing '.'

    n = text.to_s.downcase.strip
      .to_ascii
      .gsub(/['"`]/,'')
      .gsub(/\W+/,'.')
      .gsub(/((\.$)|(^\.))/, '')
      
    return "%s.%s" % [layer, n]
  end  

  def self.generate_cdk_id_with_hash(layer, id)
    return self.md5_base62(layer + "::" + id.to_s)
  end  

  def self.generate_route_cdk_id(cdk_ids)
    if cdk_ids.nil? or cdk_ids.length == 0
      return nil
    else
      return self.md5_base62(cdk_ids.join)
    end
  end
  
  ##########################################################################################
  # API request utilities
  ##########################################################################################

  def self.parse_request_json(request)
    begin  
      return JSON.parse(request.body.read)
    rescue => exception
      CitySDK_LD.do_abort(422, "Error parsing JSON - " + exception.message)
    end
  end
  
  # TODO: move to serializer? or only use JSON in (error) messages?
  def self.do_abort(code, message)
    @do_cache = false
    throw(:halt, [code, {'Content-Type' => 'application/json'}, {:status => 'fail', :message => message}.to_json])
  end  

  def self.request_format(params, req)
    case req.env['HTTP_ACCEPT']
      # accept header takes precedence
    when 'application/json'
      return :cdkjson
    when 'text/turtle'
      return :turtle
    else
      case params['format']
      when 'turtle', 'ttl'
        return :turtle
      when 'json'
        return :cdkjson
      when 'geojson'
        return :geojson
      when 'jsonld'
        return :jsonld
      else
        # json if nothing specified
        return :cdkjson
      end
    end
  end
  
  def self.mime_type(format)
    case format
    when :cdkjson, :geojson, :jsonld
      return 'application/json' 
    when :turtle
      return 'text/turtle'
    end
  end

end

##########################################################################################
# Additional functions
##########################################################################################

class String
  def round_coordinates(precision)
    self.gsub(/(\d+)\.(\d{#{precision}})\d+/, '\1.\2')
  end
end
