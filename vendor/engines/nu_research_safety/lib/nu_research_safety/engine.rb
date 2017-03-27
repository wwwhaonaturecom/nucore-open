module NuResearchSafety

  class Engine < ::Rails::Engine

    config.to_prepare do
      ::AbilityExtensionManager.extensions << "NuResearchSafety::AbilityExtension"
      Product.send :include, NuResearchSafety::ProductExtension
      ViewHook.add_hook "admin.shared.sidenav_global",
                        "after",
                        "nu_research_safety/shared/certificates_tab"
      ViewHook.add_hook "admin.shared.tabnav_product",
                        "after",
                        "nu_research_safety/shared/product_certification_requirements_tab"
      ViewHook.add_hook "admin.shared.tabnav_users",
                        "after",
                        "nu_research_safety/shared/user_certificates_tab"
    end

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

    initializer "model_core.factories", after: "factory_girl.set_factory_paths" do
      if defined?(FactoryGirl)
        FactoryGirl.definition_file_paths << File.expand_path("../../../spec/factories", __FILE__)
      end
    end

  end

end
