module Acgt

  class Engine < Rails::Engine

    config.to_prepare do
      SangerSequencing::SubmissionsController.send(:include, Acgt::SubmissionsControllerExtension)
    end

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

  end

end
