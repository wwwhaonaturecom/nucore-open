module Nucs
  class Engine < Rails::Engine
    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")

    config.to_prepare do
      FacilityAccount.send :include, NucsValidations::FacilityAccount
    end
  end
end