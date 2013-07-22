source 'https://rubygems.org'

## base
gem 'rails',            '3.2.13'
gem 'rails_config',     '0.3.3'

## database
gem 'foreigner',        '1.1.1'
gem 'activerecord-oracle_enhanced-adapter', '1.4.2'
gem 'ruby-oci8',        '2.1.5'

## deployment
gem 'capistrano',       '2.15.4'
gem 'capistrano-ext',   '1.2.1'

## auth
gem 'devise',           '2.2.4'
gem 'devise-encryptable', '0.1.2'
gem 'devise_ldap_authenticatable', '0.6.1'
gem 'cancan',           '1.6.10'

## models
gem 'aasm',             '2.2.0'
gem 'paperclip',        '~> 2.7.5'
gem 'vestal_versions',  '1.2.4.3', :git => 'git://github.com/elzoiddy/vestal_versions.git'
gem 'awesome_nested_set', '2.1.6'
gem 'nokogiri',         '1.5.9'

## views
gem 'bootstrap-sass'
gem 'haml',             '4.0.3'
gem 'will_paginate',    '3.0.4'
gem 'dynamic_form',     '~> 1.1.4'
gem 'ckeditor'
gem 'jquery-rails',     '~> 2.1.4'
gem 'jquery-ui-sass-rails'
gem 'clockpunch',       '~> 0.1.0'
gem 'simple_form'
gem 'font-awesome-rails'

## controllers
gem 'prawn',            '0.12'
gem 'prawn_rails',      '0.0.11'

## monitoring
gem 'newrelic_rpm',     '~> 3.6'
gem 'exception_notification', :require => 'exception_notifier'

## other
gem 'rake'
gem 'spreadsheet',      '~> 0.6.5.5'
gem 'fast-aes',         '0.1.1'
gem 'pdf-reader',       '1.3.3'
gem 'exception_notification', :require => 'exception_notifier'
gem 'daemons',          '1.1.9'

## custom
gem 'c2po',             '~> 1.0.0', :path => 'vendor/engines/c2po'
gem 'nu',               '~> 1.0.0', :path => 'vendor/engines/nu'
gem 'nucs',             '~> 1.0.0', :path => 'vendor/engines/nucs'
gem 'pmu',              '~> 1.0.0', :path => 'vendor/engines/pmu'
gem 'jxml',             '~> 1.0.0', :path => 'vendor/engines/jxml'
gem 'nu_cancer_center', '~> 1.0.0', :path => 'vendor/engines/nu_cancer_center'

gem 'synaccess_connect', '0.2.1', :git => 'git://github.com/tablexi/synaccess.git'

group :development, :test do
  gem 'awesome_print',     '1.1.0'
  gem 'ci_reporter'
  gem 'factory_girl_rails','4.2.1'
  gem 'pry-rails',         '0.2.2'
  gem 'quiet_assets'
  gem 'rspec-rails',       '2.13.2'
  gem 'ruby-debug19',      '0.11.6'
  gem 'shoulda-matchers',  '2.1'
  gem 'single_test',       '0.4.0'
  gem 'spork',             '0.9.2'
  gem 'timecop',           '0.6.1'

  # http://devnet.jetbrains.com/message/5479367
  # don't require in RubyMine since ruby-debug interferes with ruby-debug-ide gem
  gem 'ruby-debug19',      '0.11.6', ENV['RM_INFO'] ? { :require => false, :platforms => [:ruby_19] } : {:platforms => [:ruby_19]}

  # NU specific
  gem 'simplecov', :platforms => [:ruby_19]
end

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 2.1.1'
  gem 'therubyracer'
  gem 'turbo-sprockets-rails3'
end

group :production, :staging do
  gem 'dispatcher'
end
