require 'date'
require 'citysdk'
require 'active_support/core_ext'
require '/var/www/csdk_cms/current/utils/sysmail.rb'

credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil
$email = ARGV[0] || (pw ? pw['email'] : nil) || 'citysdk@waag.org'
$passw = ARGV[1] || (pw ? pw[$email]  : nil) || ''
$host  = ARGV[2] || (pw ? pw['host']  : nil) || 'api.dev'

$helsSR = Faraday.new :url => "https://asiointi.hel.fi", :ssl => {:verify => false, :version => 'SSLv3'}
$helsPath = "/palautews/rest/v1/requests.json"

$layer='311.helsinki'
puts "Updating layer #{$layer}.."


begin
  $api = CitySDK::API.new($host)
  if $api.authenticate($email,$passw) == false 
    puts "Auth failure"
    exit!
  end

  $api.set_layer($layer)


  updated = 0
  new_nodes = 0

  response = $helsSR.get($helsPath)

  if response.status == 200 
    nodes = JSON.parse(response.body);
    puts "Number of new requests: #{nodes.length}"
    nodes.each do |n|
      begin
          $api.get("/311.helsinki.#{n['service_request_id']}")
          # no exception -> node exists -> update data
          data = {
            "data" => {
              "updated_datetime" => n['updated_datetime'],
              "status" => n['status']
            }
          }
          begin 
            $api.put("/311.helsinki.#{n['service_request_id']}/311.helsinki",data)
            updated += 1
          rescue Exception => e
            puts "Exception updating node: #{e.message}" 
          end
      rescue Exception => e # node not found..
          node = {
            "id" => n['service_request_id'],
            "name" => "",
            "geom" => {
               "type" => "Point",
                "coordinates" => [
                  n['long'],
                  n['lat']
                ]
             },
             "data" => {
               "updated_datetime" => n['updated_datetime'],
               "service_request_id" => n['service_request_id'],   
               "status" => n['status']
             }
          }  
          begin 
            $api.create_node(node)
            new_nodes += 1
          rescue Exception => e
            puts "Exception creating node: #{e.message}" 
          end
      end
    end

    puts "\tupdated #{updated} nodes; added #{new_nodes} nodes.."

  else
    CitySDK.sysmail('error @ helsinki311',"Error accessing Helsinki 311 api.")
    puts "Error accessing Helsinki 311 api."
    puts response.body
  end

rescue Exception => e
  CitySDK.sysmail('error @ helsinki311',e.message)
  puts "Exception:"
  puts e.message
ensure
  $api.release()
end


