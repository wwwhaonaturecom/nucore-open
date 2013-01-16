module Pmu
  class Engine < Rails::Engine
    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")

    config.to_prepare do
      NufsAccount.send :include, Pmu::NufsAccountExtension
      GeneralReportsController.send :include, Pmu::GeneralReportsControllerExtension

      # make this engine's views override the main app's views
      paths=ActionController::Base.view_paths.dup
      index=paths.index{|p| p.to_s.include? 'pmu'}
      paths.unshift paths.delete_at(index)
      ActionController::Base.view_paths=paths
    end
  end
end
