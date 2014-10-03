set :stages, %w(staging prod)
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'

require "eye/patch/capistrano"
set :eye_config, "config/eye.yml.erb"
set(:eye_env) { fetch(:rails_env) }
