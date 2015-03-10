lock '3.2.1' # config valid only for Capistrano 3.2

set :application, "nucore"
set :repo_url, "git@github.com:tablexi/nucore-nu.git"

set :linked_files, %w{config/database.yml config/settings.local.yml config/ldap.yml config/newrelic.yml config/eye.yml.erb }
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

after 'deploy:finalize_update', 'deploy:symlink_configs', 'deploy:symlink_revision'

namespace :deploy do
  task :symlink_configs do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/vendor/engines/nucs/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/settings.pmu.yml #{release_path}/vendor/engines/pmu/config/settings.yml"
    run "ln -nfs #{deploy_to}/shared/files #{release_path}/public/files"
  end

  task :symlink_revision, :roles => :app do
    run "ln -nfs #{release_path}/REVISION #{release_path}/public/REVISION.txt"
  end

end

after :finishing, 'deploy:cleanup'

set :eye_config, "config/eye.yml.erb"
set :eye_env, ->{ {rails_env: fetch(:rails_env)} }

# We need to load a full bash shell to handle oracle db ENV variables.
namespace :eye do
  desc "Start eye with the desired configuration file"
  task :load_config, roles: -> { fetch(:eye_roles) } do
    # force a full shell
    run "bash -lc 'cd #{current_path} && #{fetch(:eye_bin)} q && #{fetch(:eye_bin)} l #{fetch(:eye_config)}'"
  end
end
