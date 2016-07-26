module Nucs

  class Engine < Rails::Engine

    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")

    config.autoload_paths << File.join(File.dirname(__FILE__), "../spec/support") if Rails.env.test?

    config.to_prepare do
      FacilityAccount.send :include, NucsValidations::FacilityAccount
      Product.send :include, NucsValidations::Product
      NufsAccount.send :include, Accounts::NucsAccountSections
      FacilityAccount.send :include, Accounts::NucsAccountSections
    end

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

  end

end
