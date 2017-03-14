# config valid only for current version of Capistrano
lock "~> 3.7.0"

set :application, "nucore"

set :repo_url, "git@github.com:tablexi/nucore-nu.git"

set :linked_files, fetch(:linked_files, []).concat(
  %w(config/database.yml config/secrets.yml config/settings.local.yml config/ldap.yml config/skylight.yml config/eye.yml.erb),
)

set :linked_dirs, fetch(:linked_dirs, []).concat(
  %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/files),
)

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
set :rollbar_env, Proc.new { fetch :rails_env }
set :rollbar_role, Proc.new { :app }
