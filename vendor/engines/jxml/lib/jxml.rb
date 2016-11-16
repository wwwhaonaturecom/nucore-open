module Jxml

  class Engine < Rails::Engine

    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")

    def self.enable!
      # Add views to view hooks in main rails app
      ViewHook.add_hook "admin.shared.sidenav_global", "after", "jxml_holidays/shared/jxml_tab"
    end

    # This needs to undo everything that enable! does. Used in specs for testing for turning the feature on or off
    def self.disable!
      ViewHook.remove_hook "admin.shared.sidenav_global", "after", "jxml_holidays/shared/jxml_tab"
    end

    config.to_prepare do
      # make this engine's views override the main app's views
      paths = ActionController::Base.view_paths.to_a
      index = paths.find_index { |p| p.to_s.include? "jxml" }
      paths.unshift paths.delete_at(index)
      ActionController::Base.view_paths = paths

      Jxml::Engine.enable!
    end

  end

end
