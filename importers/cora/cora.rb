# encoding: UTF-8
require 'citysdk'

credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil
$email = ARGV[0] || (pw ? pw['email'] : nil) || 'citysdk@waag.org'
$passw = ARGV[1] || (pw ? pw[$email]  : nil) || ''
$host  = ARGV[2] || (pw ? pw['host']  : nil) || 'api.dev'

layers = [
  "projecten", 
  "omleidingen",
  "belemmeringen"
]

begin  
  layers.each { |layer|    
    
    importer = CitySDK::Importer.new ({
        :file_path => "#{layer}.geojson", 
        :host => $host, 
        :email => $email,
        :passw => $passw,
        :layername => "divv.cora.#{layer}"
      })
      
    puts JSON.pretty_generate(importer.params)
    
    importer.params[:srid] = 28992
    
    importer.doImport do |params| 
      
    end

  }
end