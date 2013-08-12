require 'sinatra'

class CSDKRdf < Sinatra::Base

  get '/' do
    send_file './public/citysdk.ttl', :type => 'text/turtle', :disposition => :inline
  end

end