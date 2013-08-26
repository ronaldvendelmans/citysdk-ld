set :stages, %w(production testing opt)
set :default_stage, "testing"
require 'capistrano/ext/multistage'
#require "bundler/capistrano"


set :application, "CSDKRdf"
set :repository,  "."
set :scm, :none


set :branch, "master"

set :deploy_to, "/var/www/rdf.citysdk"

set :deploy_via, :copy

set :use_sudo, false
set :user, "citysdk"

default_run_options[:shell] = '/bin/bash'


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  # Assumes you are using Passenger
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
 
  task :finalize_update, :except => { :no_release => true } do
    run <<-CMD
      rm -rf #{latest_release}/log &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD
  end
end  


