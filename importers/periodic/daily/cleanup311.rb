require 'date'
require 'citysdk'
require '/var/www/csdk_cms/current/utils/sysmail.rb'


credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil
$email = ARGV[0] || (pw ? pw['email'] : nil) || 'citysdk@waag.org'
$passw = ARGV[1] || (pw ? pw[$email]  : nil) || ''
$host  = ARGV[2] || (pw ? pw['host']  : nil) || 'api.dev'


$layer = '311.*'
$api = CitySDK::API.new($host)

begin
  if $api.authenticate($email,$passw) == false 
    puts "Auth failure"
    exit!
  end

  puts "Cleaning up layer #{$layer}.."

  url = "nodes?skip_webservice&layer=311.*&per_page=50"
  page = 1
  count = 0
  now = Date.today
  begin
    resp = $api.get(url + "&page=#{page}")
    
    if resp['status'] == 'success' and resp['results']
      resp['results'].each do |n|
        u = Date.parse n['layers'][$layer]['data']['updated_datetime']
        if (now - u).to_i > 90 
          $api.delete("/#{n['cdk_id']}/#{$layer}?delete_node=true")
          count += 1
        end
      end
    end
    page = resp['next_page'].to_i
  end while page > 0

  puts "\tdeleted #{count} nodes."

rescue Exception => e
  puts "Error cleaning cleaning up 311 layers:\n\t#{e.message}"
  CitySDK.sysmail('Error cleaning up 311 layers.',e.message)
ensure
  $api.release()
end

