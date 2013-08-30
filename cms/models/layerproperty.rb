require "sequel/model"
class LayerProperty < Sequel::Model(:ldprops)
  set_primary_key [:layer_id, :key]
  unrestrict_primary_key
  def serialize 
    {
      "type"  =>  self.type,
      "descr" =>  self.descr,
      "lang" => self.lang,
      "unit" => self.unit.gsub(/^csdk:unit/,'')
    }
  end
  
end

