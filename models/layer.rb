require "sequel/model"

class Layer < Sequel::Model
  many_to_one :owner
  one_to_many :node_data, :class => :NodeDatum

	plugin :validation_helpers
  plugin :json_serializer

  def validate
    super
    validates_presence [:name, :description, :organization, :category]
    validates_unique :name
    validates_format /^\w+(\.\w+)*$/, :name
    validates_format /^\w+\.\w+$/, :category

    cname = self.category.split('.')[0]
    if Category.where(:name => cname).first == nil
      errors.add(:category,"Cannot be '#{cname}'")
    end

  end

  # def validate
  #   super
  #   validates_presence [:body, :latitude, :longitude]
  # end

  # TODO: make global function, for all memcache keys
  KEY_LAYER_NAMES = "layer_names"
  KEY_LAYERS_AVAILABLE = "layers_available"
  def self.memcached_key(id)
    "layer!!#{id}"
  end

  def self.get_layer(id)
    self.ensure_layer_cache
    key = self.memcached_key(id)
    CitySDKLD.memcached_get(key)
  end

  def self.get_layer_names
    self.ensure_layer_cache
    CitySDKLD.memcached_get(KEY_LAYER_NAMES)
  end

  def self.ensure_layer_cache
    if not CitySDKLD.memcached_get(KEY_LAYERS_AVAILABLE)
      self.get_layer_hashes
    end
  end

  def self.get_validity(id)
    layer = self.get_layer(id)
    if layer[:realtime]
      return true, layer[:update_rate]
    else
      return false, layer[:validity]
    end
  end

  # TODO: params needed here?
  def self.make_hash(l, params)
    l.delete :validity
    l.delete :import_config

    l[:context] = JSON.parse(l[:context], {symbolize_names: true}) if l[:context]

    # TODO: use Serializer::PRECISION
    l[:wkt] = l[:wkt].round_coordinates(6) if l[:wkt]
    l[:geojson] = JSON.parse(l[:geojson].round_coordinates(6), {symbolize_names: true}) if l[:geojson]

    l[:data_sources] = l[:data_sources] ? l[:data_sources].map { |s| s.index('=') ? s[s.index('=')+1..-1] : s } : []

    l
  end

  def self.id_from_name(p)
    # Accepts full layer names and layer names
    # with wildcards after dot layer separators:
    #    cbs.*
    case p
    when Array
      return p.map do |name| self.id_from_name(name) end.flatten.uniq
    when String
      layer_names = self.get_layer_names
      if layer_names
        if p.include? "*"
          # wildcards can only be used once, on the end of layer specifier after "." separator
          if p.length >= 3 and p.scan("*").size == 1 and p.scan(".*").size == 1 and p[-2,2] == ".*"
            prefix = p[0..(p.index("*") - 1)]
            return layer_names.select{|k,v| k.start_with? prefix}.values
          else
            CitySDKLD.do_abort(422,"You can only use wildcards in layer names directly after a name separator (e.g. osm.*)")
          end
        else
          return layer_names[p]
        end
      else
        # No layer names available, something went wrong
        CitySDKLD.do_abort(500,"Layer cache unavailable")
      end
    end
  end

  def self.name_from_id(id)
    layer = self.get_layer(id)
    layer[:name]
  end

  ##########################################################################################
  # Real-time/web service layers:
  ##########################################################################################

  def self.is_realtime?(id)
    layer = self.get_layer(id)
    layer[:realtime]
  end

  def self.is_webservice?(id)
    layer = self.get_layer(id)

    webservice = layer[:webservice]
    if layer[:name] == 'ns'
      webservice = false
    end

    return (webservice and webservice.length > 0)
  end

  def self.get_webservice_url(id)
    layer = self.get_layer(id)
    layer[:webservice]
  end

  def self.get_data(id, node_id, data)
    WebService.load(id, node_id, data)
  end

  def self.get_data_timeout(id)
    layer = self.get_layer(id)
    layer[:update_rate] || 3000
  end

  ##########################################################################################
  # Initialize layers hash:
  ##########################################################################################

  def self.get_layer_hashes
    names = {}

    columns = (Layer.dataset.columns - [:bbox])
    Layer.select{columns}.select_append(
      Sequel.function(:ST_AsGeoJSON, :bbox).as(:geojson),
      Sequel.function(:ST_AsText, :bbox).as(:wkt)
    ).all.each do |l|
      l.values[:owner] = Owner.make_hash Owner.where(:id => l.values[:owner_id]).first
      l.values[:fields] = LayerProperty.where(:layer_id => l.values[:id]).all.map { |l| LayerProperty.make_hash l.values }

      layer = make_hash l.values, nil

      # Save layer data in memcache without expiration
      key = self.memcached_key(layer[:id].to_s)
      CitySDKLD.memcached_set(key, layer, 0)
      names[layer[:name]] = layer[:id]
    end

    CitySDKLD.memcached_set(KEY_LAYER_NAMES, names, 0)
    CitySDKLD.memcached_set(KEY_LAYERS_AVAILABLE, true, 0)
  end

end
