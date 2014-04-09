require "sequel/model"

class Modality < Sequel::Model
  
	plugin :validation_helpers
  plugin :json_serializer
  
  @@modalityIdHash = {};
  @@modalityNameHash = {};

  def serialize(params)
    h = {
      :id => id,
      :name => name,
    }
    h
  end
  
  def self.id_from_name(p)
    case p
      when Array
        return p.map do |m| @@modalityIdHash[m] end
      when String
        return @@modalityIdHash[p]
    end
  end
 
  def self.name_from_id(id)
    @@modalityNameHash[id] ||= Modality[id].name
  end

  ##########################################################################################
  # Initialize Modalities hash:
  ##########################################################################################

  def self.get_modality_hashes
    Modality.all.each do |m|
      @@modalityIdHash[m[:name]] = m[:id]
    end
  end 
end

Modality.get_modality_hashes




