require 'json'
require 'base64'
require 'sequel'
require 'tmpdir'
require 'citysdk'

dbconf = '/var/www/citysdk/shared/config/database.json'
dbconf = File.exists?(dbconf) ? JSON.parse(File.read(dbconf)) : nil

if dbconf.nil?
  puts "Database credentials not provided, exitting.."
  exit!
end

DB = Sequel.connect( "postgres://#{dbconf['user']}:#{dbconf['password']}@#{dbconf['host']}/#{dbconf['database']}" )

class Layer < Sequel::Model
end
class Owner < Sequel::Model
end




def one_file(f)
  imp = CitySDK::Importer("test-api.citysdk.waag.org")
end

def do_one(layer)
  begin 
    Dir.mktmpdir {|dir|
      if system "wget -P #{dir} '#{layer.import_url}'"
        Dir.open(dir).each do |f|
          next if f =~ /^\./
          return one_file(dir + "/" + f)
        end
      end
    }
  rescue Exception => e
    puts "Exception: #{e.message}"
  end
  false
end


layers = Layer.where(:import_period => 'daily').all

layers.each do |l|
  puts "#{l.name}\t#{l.import_url}"
  params = JSON.parse(Base64::decode64(l.import_config), {:symbolize_names => true} )
  
  # puts(JSON.pretty_generate(params))
  lm = `curl --silent --head '#{l.import_url}' | grep Last-Modified`
  if lm =~ /.*,\s+(.*)\s+\d\d:/
    if l.import_last_update.nil? or (Date.parse($1) > Date.parse(l.import_last_update))
      nd = $1
      if do_one(l)
        l.import_last_update = nd
        l.save
      end
    end
  end
end

