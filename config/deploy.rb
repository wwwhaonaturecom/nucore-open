set :stages, %w(staging prod)
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'
