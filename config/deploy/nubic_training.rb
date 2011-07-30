set :application, "nucore"

set  :user, "jgi913"
set  :deploy_to, "/var/www/apps/nucore"
set  :rails_env, "staging"
role :web, "admin-staging.nubic.northwestern.edu"                          # Your HTTP server, Apache/etc
role :app, "admin-staging.nubic.northwestern.edu"                          # This may be the same as your `Web` server
role :db,  "admin-staging.nubic.northwestern.edu", :primary => true        # This is where Rails migrations will run

default_run_options[:pty] = true
set :use_sudo, false
ssh_options[:forward_agent] = true

set :repository, "git@github.com:tablexi/nucore-nu.git"
set :deploy_via, :export
set :scm, "git"
set :branch, "master"

default_environment["LD_LIBRARY_PATH"] = "/usr/lib/oracle/11.1/client64/lib"
default_environment["ORACLE_HOME"] = "/usr/lib/oracle/11.1/client64/lib"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :except => { :no_release => true } do
    run "touch #{release_path}/tmp/restart.txt && chmod -R g+w #{release_path}/tmp"
  end
  task :symlink_configs do
    run "ln -s #{deploy_to}/database.yml #{release_path}/config/database.yml"
    run "ln -s #{deploy_to}/Constants.rb #{release_path}/config/Constants.rb"
    run "ln -s #{deploy_to}/files #{release_path}/public/files"
  end
  task :bundle_install do
    run "cd #{release_path} && ~/.gem/ruby/1.8/bin/./bundle install ../../shared/bundle"
  end
  task :chmod_project do
    run "chmod -R g+w #{release_path}"
    run "chmod -R g+w #{release_path}/../../shared/bundle"
  end
end

after 'deploy:update_code', 'deploy:symlink_configs', 'deploy:bundle_install', 'deploy:chmod_project'
