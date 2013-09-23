require "sequel/model"

class LDPrefix < Sequel::Model(:ldprefix)
end


class LayerProperty < Sequel::Model(:ldprops)
  set_primary_key [:layer_id, :key]
  unrestrict_primary_key
  def serialize 
    {
      "type"  =>  self.type,
      "descr" =>  self.descr,
      "lang" => self.lang,
      "eqprop" => self.eqprop,
      "unit" => self.unit ? self.unit.gsub(/^csdk:unit/,'') : nil
    }
  end
  
end

