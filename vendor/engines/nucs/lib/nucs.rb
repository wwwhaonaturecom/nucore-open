module Nucs
  class Engine < Rails::Engine
    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")

    config.to_prepare do
      FacilityAccount.send :include, NucsValidations::FacilityAccount
      Product.send :include, NucsValidations::Product
      NufsAccount.send :include, Accounts::NucsAccountSections
      FacilityAccount.send :include, Accounts::NucsAccountSections
    end
  end
end
