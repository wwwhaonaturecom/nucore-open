module NuResearchSafety

  class Engine < ::Rails::Engine

    config.to_prepare do
      ViewHook.add_hook "admin.shared.sidenav_global",
                        "after",
                        "nu_research_safety/shared/certificates_tab"
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
