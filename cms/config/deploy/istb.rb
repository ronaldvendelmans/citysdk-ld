puts "\n\n"
puts "*** Deploying to \033[1;41mIstanbul\033[0m"
puts "\n\n"

server '212.174.15.26', :app, :web, :primary => true
