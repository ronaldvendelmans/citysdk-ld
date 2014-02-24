
module Serializer
  
  def self.serialize(format, type, objects, layers, meta)
    # TODO: 'register/plug-in' pattern
    case format
    when :turtle
      TurtleSerializer.serialize type, objects, layers, meta
    when :json
      JSONSerializer.serialize type, objects, layers, meta
    when :geojson
      GeoJSONSerializer.serialize type, objects, layers, meta
    when :jsonld
      JSONldSerializer.serialize type, objects, layers, meta
    end
  end
  
  class Base
    
    #########################################################################
    # Base seralization function
    #########################################################################
    
    def self.serialize(type, objects, layers, meta)
      # TODO: is this ok? and safe?
      @type = type
      @objects = objects
      @layers = layers
      @meta = meta
      
      self.start 
      case type
      when :nodes
        self.nodes
      when :layers
        self.layers
      end
      self.end
    end
    
    #########################################################################
    # Serializer-specific functions - overridden in separete serializers
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
    
    def self.status
      CitySDK_API.do_abort(401,"Serialization error - status not implemented")
    end
    
    def self.nodes
      CitySDK_API.do_abort(401,"Serialization error - nodes not implemented")
    end
    
    def self.layers
      CitySDK_API.do_abort(401,"Serialization error - layers not implemented")
    end
    
    def self.message
      CitySDK_API.do_abort(401,"Serialization error - message not implemented")      
    end
    
  end
end