require 'citysdk'
require '/var/www/csdk_cms/current/utils/sysmail.rb'

credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil
$email = ARGV[0] || (pw ? pw['email'] : nil) || 'citysdk@waag.org'
$passw = ARGV[1] || (pw ? pw[$email]  : nil) || ''
$host  = ARGV[2] || (pw ? pw['host']  : nil) || 'api.dev'

# Rijkswaterstaat waterdata

layers = {
  "temp" => "watertemperatuur",
  "nap" => "waterstanden"
}


begin
  $api = CitySDK::API.new($host)

  $api.authenticate($email,$passw)

  layers.each { |layer, rws_name| 

    ###### Download RWS data ######
    puts "Downloading RWS data: #{rws_name}..."

    rws_url = 'http://www.rijkswaterstaat.nl'
    rws_conn = Faraday.new(:url => rws_url)
    response = rws_conn.get '/apps/geoservices/rwsnl/', { :mode => 'features', :projecttype => rws_name, :loadprojects => 0 }
    results = JSON.parse(response.body)

    nodes = results['features'].map do |l|
      {
        :id => l['loc'],
        :name => l['locatienaam'],
        :geom => {
          :type => :Point,
          :coordinates => [
            l['location']['lon'].to_f,
            l['location']['lat'].to_f
          ]
        },
        :data => {
          :waarde => l['waarde'].to_i, # TODO: check for NULL
          :meettijd => Time.at(l['meettijd'].to_i)
        }
      }
    end

    puts "Received #{nodes.length} nodes.."
    $stderr.puts "Received #{nodes.length} nodes.."

    $api.set_layer("rws.#{layer}")

    $api.set_createTemplate( {
      :create => {
        :params => {
          :create_type => "create",
          :srid => 28992
        }
      }
    } )

    nodes.each do |n|
      $api.create_node(n)
    end

  }
rescue Exception => e
  puts "Error updating rws data:\n\t#{e.message}"
  CitySDK.sysmail('Error updating rws data.',e.message)
ensure
  $api.release
end

