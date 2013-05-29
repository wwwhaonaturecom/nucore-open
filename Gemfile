source 'https://rubygems.org'

## base
gem 'rails',            '3.0.20'
gem 'rails_config',     '0.2.5'

## database
gem 'foreigner',        '1.1.1'
gem 'activerecord-oracle_enhanced-adapter', '1.3.0'
# ruby-oci8 won't compile on lion
unless (RUBY_PLATFORM =~ /x86_64-darwin11/)
  gem 'ruby-oci8',        '2.1.5'
end

## auth
gem 'devise',           '1.3.4'
gem 'cancan',           '1.6.8'
gem 'devise_ldap_authenticatable', '0.4.3'

## deployment
gem 'capistrano',       '2.6.0'
gem 'capistrano-ext',   '1.2.1'

## models
gem 'aasm',             '2.2.0'
gem 'paperclip',        '~> 2.3.12'
gem 'awesome_nested_set', '2.0.1'
gem 'nokogiri',         '1.4.4'
gem 'vestal_versions',  '1.2.4.3', :git => 'git://github.com/elzoiddy/vestal_versions.git'

## views
gem 'haml',             '3.1.2'
gem 'will_paginate',    '3.0.2'
gem 'jquery-rails',     '1.0.12'
gem 'json',             '1.7.7'

## controllers
gem 'prawn',            '0.12'
gem 'prawn_rails',      '0.0.5'

## monitoring
gem 'newrelic_rpm',     '~> 3.6'
gem 'exception_notification', :require => 'exception_notifier'

## other
gem 'rake'
gem 'spreadsheet',      '~> 0.6.5.5'
gem 'fast-aes',         '0.1.1'
gem 'fastercsv',        '1.5.4'
gem 'pdf-reader',       '1.3.2'
gem 'daemons',          '1.1.6'

## custom
gem 'c2po',             '~> 1.0.0', :path => 'vendor/engines/c2po'
gem 'nu',               '~> 1.0.0', :path => 'vendor/engines/nu'
gem 'nucs',             '~> 1.0.0', :path => 'vendor/engines/nucs'
gem 'pmu',              '~> 1.0.0', :path => 'vendor/engines/pmu'
gem 'jxml',             '~> 1.0.0', :path => 'vendor/engines/jxml'

source 'http://download.bioinformatics.northwestern.edu/gems/'
gem 'bcsec',             '2.1.1', :require => 'pers'
gem 'bcdatabase',        '1.0.6'
gem 'schema_qualified_tables', '1.0.0'

gem 'synaccess_connect', '0.2.0', :git => 'git://github.com/tablexi/synaccess.git'

group :development, :test do
  gem 'ci_reporter'

  # TODO upgrade factory girl to 4.1 once we no longer need to support
  # ruby 1.8.7. FactoryGirl 3 only supports 1.9.2
  gem 'factory_girl_rails','1.7.0'
  gem 'rspec-rails',       '2.9'
  gem 'shoulda-matchers',  '1.4.2'
  gem 'single_test',       '0.4.0'
  gem 'spork',             '0.9.2'
  gem "pry-rails",         '0.2.2'
  gem "awesome_print",     '1.1.0'

  # http://devnet.jetbrains.com/message/5479367
  # don't require in RubyMine since ruby-debug interferes with ruby-debug-ide gem
  gem 'ruby-debug',        '0.10.3', ENV['RM_INFO'] ? { :require => false, :platforms => [:ruby_18] } : {:platforms => [:ruby_18]}
  gem 'ruby-debug19',      '0.11.6', ENV['RM_INFO'] ? { :require => false, :platforms => [:ruby_19] } : {:platforms => [:ruby_19]}

  # NU specific
  gem 'rcov', :platforms => [:ruby_18]
  gem 'simplecov', :platforms => [:ruby_19]
  gem 'silent-oracle'
end

group :test do
  # Newer versions of timecop don't support 1.8.7
  gem 'timecop',           '0.3.5'
end

group :production, :staging do
  gem 'dispatcher'
end
