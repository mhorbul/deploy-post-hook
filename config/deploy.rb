set :application, "deploy-webhook"
set :repository,  "git://github.com/mhorbul/deploy-post-hook.git"

set :scm, :git
set :branch, (ENV['branch'] || 'master')

set :deploy_via, :remote_cache

server "serra.ponticlaro.com", :app, :web, :db, :primary => true

set :deploy_to, "/home/0000000/apps/#{application}"
set :user, "cibo"
set :use_sudo, false
set :http_port, 9000

ssh_options[:forward_agent] = true

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

after "deploy:setup" do
  run "mkdir -p #{shared_path}/bundle"
end

after "deploy:update_code", "bundle:install"

namespace :deploy do
  task :start do
    run("cd #{current_path} && PORT=#{http_port} ./start")
  end
  task :stop do
    run "if [ -f '#{shared_path}/pids/web.pid' ]; then kill -TERM $(cat #{shared_path}/pids/web.pid) && rm -rf #{shared_path}/pids/web.pid; fi; exit 0"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    sleep(5)
    start
  end
end

namespace :bundle do
  task :install do
    run "mkdir -p #{current_path}/vendor"
    run "cd #{current_path} && rm -rf vendor/bundle && ln -sf #{shared_path}/bundle vendor/bundle"
    run "cd #{current_path } && bundle install --quiet --deployment --without=deployment development test"
  end
end
