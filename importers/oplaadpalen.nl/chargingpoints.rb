require 'citysdk'
require 'tempfile'

OPLAADPALEN_KEY = JSON.parse(File.read('/var/www/citysdk/shared/config/oplaadpalen_key.json'))["key"]
OPLAADPALEN_HOST = "http://oplaadpalen.nl"
OPLAADPALEN_PATH = "/api/chargingpoints/#{OPLAADPALEN_KEY}/json"

credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil

$email = ARGV[0] || (pw ? pw['email'] : nil) || 'citysdk@waag.org'
$passw = ARGV[1] || (pw ? pw[$email]  : nil) || ''
$host  = ARGV[2] || (pw ? pw['host']  : nil) || 'api.dev'

layer = "oplaadpalen"

begin  
  
  # Match http://dev.citysdk.waag.org/map#admr.nl.nederland/nodes?osm::amenity=charging_station
  # TODO: download json from OPLAADPALEN_PATH
  importer = CitySDK::Importer.new ({
      :file_path => "chargingpoints.json", 
      :host => $host, 
      :email => $email,
      :passw => $passw,
      :layername => layer
    })
  
  puts JSON.pretty_generate(importer.params)
  
  importer.doImport do |params|
  end

end

# Example object:

# {
#     "id": "3176",
#     "lng": "5.65562",
#     "lat": "53.034101",
#     "name": "E-laad AL200",
#     "address": "Sint Antoniusplein 1",
#     "postalcode": "8601 HJ",
#     "city": "Sneek",
#     "country": "NL",
#     "phone": "0800-3522365",
#     "url": "http://www.e-laad.nl",
#     "owner": "e-laad",
#     "email": "",
#     "opentimes": "",
#     "chargetype": "AC krachtstroom",
#     "connectortype": "mennekes",
#     "nroutlets": "1",
#     "cards": [
#         "elaad",
#         "thenewmotion",
#         "essent",
#         "eneco",
#         "nuon",
#         "travelcard",
#         "alfen",
#         "mrgreen",
#         "chargepnt",
#         "evbox",
#         "grwheel",
#         "ecogo",
#         "greenflux",
#         "bluecorner",
#         "anwb"
#     ],
#     "pricemethod": "jaarabonnement",
#     "price": "0.00",
#     "power": "11kW",
#     "vehicle": "auto",
#     "facilities": [
#         "parkeer",
#         "restaurant",
#         "koffiecorner",
#         "shop",
#         "winkelcentrum",
#         "openbaar vervoer"
#     ],
#     "realtimestatus": true
# }