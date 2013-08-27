require "sequel/model"
class LayerProperty < Sequel::Model(:ldprops)
  
  def serialize 
    {
      "type"  =>  self.type,
      "descr" =>  self.descr,
      "lang" => self.lang
    }
  end
  
end

