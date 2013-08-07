puts "\n\n"
puts "*** Deploying to \033[1;41mLamia\033[0m"
puts "\n\n"

server '79.129.44.176', :app, :web, :primary => true
