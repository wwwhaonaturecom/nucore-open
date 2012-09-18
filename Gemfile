source :gemcutter

## base
gem 'rails',            '3.0.14'
gem 'rails_config',     '0.2.5'

## database
gem 'foreigner',        '1.1.1'
gem 'activerecord-oracle_enhanced-adapter', '1.3.0'
# ruby-oci8 won't compile on lion
unless (RUBY_PLATFORM =~ /x86_64-darwin11/)
  gem 'ruby-oci8',        '2.0.4'
end

## auth
gem 'devise',           '1.3.4'
gem 'cancan',           '1.6.7'
gem 'devise_ldap_authenticatable', '0.4.3'

## deployment
gem 'capistrano',       '2.6.0'
gem 'capistrano-ext',   '1.2.1'

## models
gem 'aasm',             '2.2.0'
gem 'paperclip',        '2.3.12'
gem 'awesome_nested_set', '2.0.1'
gem 'nokogiri',         '1.4.4'
gem 'vestal_versions',  '1.2.4.3', :git => 'git://github.com/elzoiddy/vestal_versions.git'

## views
gem 'haml',             '3.1.2'
gem 'will_paginate',    '3.0.2'
gem 'jquery-rails',     '1.0.12'

## controllers
gem 'prawn',            '0.12.0'
gem 'prawn_rails',      '0.0.5'

## monitoring
gem 'newrelic_rpm',     '~> 3.4.1'
gem 'exception_notification', :require => 'exception_notifier'

## other
gem 'rake',             '0.8.7'
gem 'ruby-ole',         '1.2.11.1'
gem 'spreadsheet',      '0.6.5.5'
gem 'fast-aes',         '0.1.1'
gem 'pdf-reader',       '0.10.1'
gem 'fastercsv',        '1.5.4'
gem 'daemons',          '1.1.6'

## custom
gem 'nucs',             '~> 1.0.0', :path => 'vendor/engines/nucs'
gem 'c2po',             '~> 1.0.0', :path => 'vendor/engines/c2po'
gem 'nu',               '~> 1.0.0', :path => 'vendor/engines/nu'

source 'http://download.bioinformatics.northwestern.edu/gems/'
gem 'bcsec',             '2.1.1', :require => 'pers'
gem 'bcdatabase',        '1.0.6'
gem 'schema_qualified_tables', '1.0.0'

group :development, :test do
  gem 'rspec-rails', '2.9'
  gem 'spork', '0.9.0.rc9'
  gem 'mocha', '0.9.7'
  gem 'factory_girl_rails', '1.0.1'
  gem 'shoulda', '2.11.3'
  gem 'ruby-debug', '0.10.3'
  gem 'single_test', '0.4.0'
  gem 'ci_reporter'
  gem 'timecop'
  gem 'rcov'
end

group :production, :staging do
  gem 'dispatcher'
end
