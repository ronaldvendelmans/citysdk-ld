if ARGV[0]

  csv = nil
  
  begin 

    require 'citysdk'

    puts "\nFile import at #{Time.now.strftime('%b %d %Y - %H:%M:%S')}"

    params = JSON.parse(ARGV[0], {:symbolize_names => true} )

    puts "\tlayer: #{params[:layername]}\n\tfile: #{params[:originalfile]}"  

    # puts "params: #{JSON.pretty_generate(params)}"

    
    csv = CitySDK::Importer.new(params)
    
    csv.setLayerStatus("importing...")
    
    ret = csv.doImport do |h|
      puts JSON.pretty_generate(h)
    end

    s = "updated: #{ret[:updated]}; added: #{ret[:created]}; not added: #{ret[:not_added]}"
    puts s
    
    csv.setLayerStatus(s)
    

  rescue Exception => e
    csv.setLayerStatus(e.message) if csv
    puts "Exception: #{e.message}"
    puts e.backtrace
  end

end


