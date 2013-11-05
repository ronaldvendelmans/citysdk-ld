set :stages, %w(production testing opt)
set :default_stage, "production"
require 'capistrano/ext/multistage'
#require "bundler/capistrano"


set :application, "CSDKDoc"
set :repository,  "."
set :scm, :none

set :copy_exclude, ['config.json','tmp']

set :branch, "master"

set :deploy_to, "/var/www/dev.citysdk"

set :deploy_via, :copy

set :use_sudo, false
set :user, "bert"

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
      ln -s /var/www/citysdk/shared/config/config.json #{release_path} &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD
    
    run "ln -s /var/www/csdk_cms/current/utils/citysdk_api.rb #{release_path}/public/citysdk_api.rb"
  end
end  


