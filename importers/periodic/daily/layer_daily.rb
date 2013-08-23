require 'json'
require 'base64'
require 'sequel'
require 'tmpdir'
require 'citysdk'
require '/var/www/csdk_cms/current/utils/sysmail.rb'

credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil
$email = ARGV[0] || (pw ? pw['email'] : nil) || 'citysdk@waag.org'
$passw = ARGV[1] || (pw ? pw[$email]  : nil) || ''
$host  = ARGV[2] || (pw ? pw['host']  : nil) || 'api.dev'

dbconf = '/var/www/citysdk/shared/config/config.json'
dbconf = File.exists?(dbconf) ? JSON.parse(File.read(dbconf)) : nil

if dbconf.nil?
  puts "Database credentials not provided, exitting.."
  exit!
end

DB = Sequel.connect( "postgres://#{dbconf['db_user']}:#{dbconf['db_pass']}@#{dbconf['db_host']}/#{dbconf['db_name']}" )

class Layer < Sequel::Model
end
class Owner < Sequel::Model
end

def one_file(f,params)
  params[:file_path] = f
  params[:email] = $email
  params[:passw] = $passw
  params[:host]  = $host
  imp = CitySDK::Importer.new(params)
  
  puts(JSON.pretty_generate(imp.params))
  false
end

def do_one(layer,params)
  begin 
    Dir.mktmpdir {|dir|
      if system "wget -P #{dir} '#{layer.import_url}'"
        Dir.open(dir).each do |f|
          next if f =~ /^\./
          return one_file(dir + "/" + f,params)
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
  
  next if l.import_config.nil? or l.import_url.nil?
  
  puts "#{l.name}\t#{l.import_url}"
  params = JSON.parse(Base64::decode64(l.import_config), {:symbolize_names => true} )
  
  # puts(JSON.pretty_generate(params))
  lm = `curl --silent --head '#{l.import_url}' | grep Last-Modified`
  if lm =~ /.*,\s+(.*)\s+\d\d:/
    if l.import_last_update.nil? or (Date.parse($1) > Date.parse(l.import_last_update))
      nd = $1
      if do_one(l, params)
        l.import_last_update = nd
        l.save
      end
    end
  end
end

