if Rails.env.development? || Rails.env.test?
  require 'fileutils'
  base=File.dirname(__FILE__)

  #
  # Use the host app's config during development
  FileUtils.ln_sf File.expand_path('../../../../../config/database.yml', base), File.expand_path('../database.yml', base)
end
