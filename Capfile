load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

set :stages, %w(nubic_prod nubic_training nubic_dev_stage)
require 'capistrano/ext/multistage'

#load 'config/deploy' # remove this line to skip loading any of the default tasks