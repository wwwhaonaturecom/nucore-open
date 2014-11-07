set :stages, %w(staging prod)
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'

require "eye/patch/capistrano"
set :eye_config, "config/eye.yml.erb"
set(:eye_env) { fetch(:rails_env) }

namespace :eye do
  desc "Start eye with the desired configuration file"
  task :load_config, roles: -> { fetch(:eye_roles) } do
    # force a full shell
    run "bash -lc 'cd #{current_path} && #{fetch(:eye_bin)} q && #{fetch(:eye_bin)} l #{fetch(:eye_config)}'"
  end
end
