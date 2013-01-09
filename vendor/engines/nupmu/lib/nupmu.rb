module Nupmu
  class Engine < Rails::Engine
    config.to_prepare do
      # make this engine's views override the main app's views
      paths=ActionController::Base.view_paths.dup
      index=paths.index{|p| p.to_s.include? 'nupmu'}
      paths.unshift paths.delete_at(index)
      ActionController::Base.view_paths=paths
    end
  end
end
