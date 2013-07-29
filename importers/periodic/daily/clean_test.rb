require 'date'
require 'citysdk'
require '/var/www/csdk_cms/current/utils/sysmail.rb'

credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil
$email = ARGV[0] || (pw ? pw['email'] : nil) || 'citysdk@waag.org'
$passw = ARGV[1] || (pw ? pw[$email]  : nil) || ''
$host  = ARGV[2] || (pw ? pw['host']  : nil) || 'api.dev'


$layer = 'test.*'
$api = CitySDK::API.new($host)

begin 
  if $api.authenticate($email,$passw) == false 
    puts "Auth failure"
    exit!
  end
  count = 0

  obj = $api.get('layers?name=test')
  if obj and obj['results']
    obj['results'].each do |l|
      if l['name'] =~ /^test\..+/
        $api.delete("/layer/#{l['name']}?delete_layer=true")
        puts "\tdeleted layer: #{l['name']}."
      end
    end
  end

rescue Exception => e
  puts "Error cleaning out test layers:\n\t#{e.message}"
  CitySDK.sysmail('Error cleaning out test layers.',e.message)
ensure
  $api.release()
end




