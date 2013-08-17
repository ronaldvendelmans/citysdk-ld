require 'sinatra'
require 'rdf/turtle'
include RDF


def load_ttl
  @ents = []
  @graph = Graph.load("./public/citysdk.ttl", :format => :ttl)
  @graph.each do |t|
    s = t.subject.to_s.gsub('http://rdf.citysdk.eu/','')
    @ents << s if not (@ents.include?(s) or s == '')
  end
end

class CSDKRdf < Sinatra::Base
  
  before do
    load_ttl
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
  
  get '/asd/*' do 
    redirect "http://api.citysdk.waag.org/#{params[:splat][0]}", 303
  end

  get '/:entity' do 
    if @ents.include?(params[:entity])
      [200,{},"Found: #{params[:entity]}" ]
    else
      [404,{},"Not found: #{params[:entity]}" ]
    end
  end

  

end

