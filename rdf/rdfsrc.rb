require 'sinatra'

class CSDKRdf < Sinatra::Base
  
  
  before do
    case request.env['HTTP_ACCEPT']
      when 'application/rdf+xml'
        @type = 'application/rdf+xml'
      when 'text/turtle'
        @type = 'text/turtle'
    end
  end

  after do
  end

  get '/' do
    case @type
      when 'application/rdf+xml'
        send_file './public/citysdk.xml', :type => @type, :disposition => :inline
      when 'text/turtle'
        send_file './public/citysdk.ttl', :type => @type, :disposition => :inline
      else
        send_file './public/citysdk.ttl', :type => @type, :disposition => :inline
      end
  end

end


