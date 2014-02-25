
module Serializer
  
  def self.serialize(format, type, data, layers, meta)
    # TODO: 'register/plug-in' pattern, also register mimetype/format
    case format
    when :turtle
      TurtleSerializer.serialize type, data, layers, meta
    when :json
      JSONSerializer.serialize type, data, layers, meta
    when :geojson
      GeoJSONSerializer.serialize type, data, layers, meta
    when :jsonld
      JSONldSerializer.serialize type, data, layers, meta
    end
  end
  
  class Base
    
    #########################################################################
    # Base seralization function
    #########################################################################
    
    def self.serialize(type, data, layers, meta)
      # TODO: is this ok? and safe?
      @type = type
      @data = data
      @layers = layers
      @meta = meta
      
      self.start 
      
      # TODO: add owners, layer semantics, node data, individual key/value
      case type
      when :nodes
        self.nodes
      when :layers
        self.layers
      when :message
        self.message
      when :status
        self.status
      end
      self.end
    end
    
    #########################################################################
    # Serializer-specific functions - overridden in separate serializers
    #########################################################################
    
    # Serialization start and end
    
    def self.start
      CitySDK_API.do_abort(401,"Serialization error - start not implemented")
    end
    
    # end function returns string with serialization result 
    def self.end
      CitySDK_API.do_abort(401,"Serialization error - end not implemented")
    end
    
    # Serialization functions per object type
    
    def self.nodes
      CitySDK_API.do_abort(401,"Serialization error - nodes not implemented")
    end
    
    def self.layers
      CitySDK_API.do_abort(401,"Serialization error - layers not implemented")
    end
    
    def self.message
      CitySDK_API.do_abort(401,"Serialization error - message not implemented")      
    end

    def self.status
      CitySDK_API.do_abort(401,"Serialization error - status not implemented")
    end
    
  end
end