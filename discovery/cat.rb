require 'sinatra'
require 'rdf/turtle'
include RDF


class CSDK_CAT < Sinatra::Base
  
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
  
  get '/:c' do
  end
  
  post '/:c/:l' do
  end
  
end

