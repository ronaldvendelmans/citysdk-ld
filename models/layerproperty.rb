require "sequel/model"

class LayerProperty < Sequel::Model(:ldprops)
  def self.make_hash(l)
    {
      id: l[:key],
      lang: l[:lang],
      type: l[:type],
      unit: l[:unit],
      description: l[:descr],
      eqprop: l[:eqprop]
    }.delete_if{ |k, v| not v or v == '' }
  end
end

class Prefix < Sequel::Model(:ldprefix)
	plugin :validation_helpers
end

class OSMProps < Sequel::Model(:osmprops)

end
