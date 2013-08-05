require "sequel/model"

class Category < Sequel::Model
	plugin :validation_helpers
end

class Prefix < Sequel::Model(:ldprefix)
	plugin :validation_helpers
end

class OSMProps < Sequel::Model(:osmprops)
end





