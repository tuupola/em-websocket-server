set :application, "em-websocket-server"
set :repository, "git@github.com:tuupola/#{application}.git"
set :user, "sinatra"
set :server, "ws.appelsiini.net"
set :domain, "#{user}@#{server}"
set :deploy_to, "/srv/www/#{server}"
set :remote_port, 4567
set :local_port, 9393

require "vlad"


module Rake
  def self.remove_task(task_name)
    Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
  end
end

namespace :vlad do  
  desc "Deploy the code and restart the server"
  task :deploy => [:update, :start_app]  
  
  Rake.remove_task('vlad:update_symlinks')
  remote_task :update_symlinks, :roles => :app do
  end
end
