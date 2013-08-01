require 'citysdk'
require '/var/www/csdk_cms/current/utils/sysmail.rb'

credentials = '/var/www/citysdk/shared/config/cdkpw.json'
pw = File.exists?(credentials) ? JSON.parse(File.read(credentials)) : nil
$host  = ARGV[0] || (pw ? pw['host']  : nil) || 'api.dev'
$port  = ARGV[1] || (pw ? pw['port']  : nil) || 80

begin
  $api = CitySDK::API.new($host,$port)
rescue => e
  puts("API @ #{$host} seems to be down!!\n" + e.message)
  CitySDK.sysmail("API @ #{$host} seems to be down!!",e.message)
end

