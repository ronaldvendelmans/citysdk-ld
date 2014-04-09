
module Serializer
  
  # There's no need to output coordinates with 
  # infinite decimal places.
  # We will round all coordinates to PRECISION
  # places with the round_coordinates function.
  #
  # From: http://stackoverflow.com/questions/7167604/how-accurately-should-i-store-latitude-and-longitude  
  #
  # decimal  degrees    distance
  # places
  # -------------------------------  
  # 0        1.0        111 km
  # 1        0.1        11.1 km
  # 2        0.01       1.11 km
  # 3        0.001      111 m
  # 4        0.0001     11.1 m
  # 5        0.00001    1.11 m
  # 6        0.000001   0.111 m
  # 7        0.0000001  1.11 cm
  # 8        0.00000001 1.11 mm
  PRECISION = 6 
  
  def self.serialize(format, type, data, layers, meta)
    # TODO: 'register/plug-in' pattern, also register mimetype/format
    case format
    when :turtle
      TurtleSerializer.serialize type, data, layers, meta
    when :geojson
      GeoJSONSerializer.serialize type, data, layers, meta
    when :jsonld
      JSONLDSerializer.serialize type, data, layers, meta
    when :json
      CdkJSONSerializer.serialize type, data, layers, meta      
    else
      # default
      CdkJSONSerializer.serialize type, data, layers, meta
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
      CitySDKLD.do_abort(500,"Serialization error - start not implemented")
    end
    
    # end function returns string with serialization result 
    def self.end
      CitySDKLD.do_abort(500,"Serialization error - end not implemented")
    end
    
    # Serialization functions per object type
    
    def self.nodes
      CitySDKLD.do_abort(500,"Serialization error - nodes not implemented")
    end
    
    def self.layers
      CitySDKLD.do_abort(500,"Serialization error - layers not implemented")
    end

    def self.status
      CitySDKLD.do_abort(500,"Serialization error - status not implemented")
    end
    
  end
end