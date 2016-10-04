lock "3.4.1" # config valid only for Capistrano 3.4

set :application, "nucore"
set :repo_url, "git@github.com:tablexi/nucore-nu.git"

set :linked_files, %w(config/database.yml config/settings.local.yml config/ldap.yml config/eye.yml.erb config/skylight.yml)
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

namespace :deploy do
  task :symlink_configs do
    on roles :app do
      execute "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/vendor/engines/nucs/config/database.yml"
      execute "ln -nfs #{deploy_to}/shared/config/settings.pmu.yml #{release_path}/vendor/engines/pmu/config/settings.yml"
      execute "ln -nfs #{deploy_to}/shared/files #{release_path}/public/files"
    end
  end

  task :symlink_revision do
    on roles :app do
      execute "ln -nfs #{release_path}/REVISION #{release_path}/public/REVISION.txt"
    end
  end
end

after "deploy:updated", "deploy:symlink_configs", "deploy:symlink_revision"

after "deploy:finished", "deploy:cleanup"

set :eye_config, "config/eye.yml.erb"
set :eye_env, -> { { rails_env: fetch(:rails_env) } }

set :rollbar_token, ENV["ROLLBAR_ACCESS_TOKEN"]
set :rollbar_env, proc { fetch :stage }
set :rollbar_role, proc { :app }
