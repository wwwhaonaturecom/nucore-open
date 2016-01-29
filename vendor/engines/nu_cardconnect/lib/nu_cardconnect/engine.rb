module NuCardconnect
  class Engine < ::Rails::Engine
    initializer "nu_cardconnect.filter_params" do |app|
      app.config.filter_parameters += [:cc_number, :cc_token]
    end

    config.to_prepare do
      NuCardconnect::Engine.routes.default_url_options = ActionMailer::Base.default_url_options

      if Settings.cardconnect.present?
        CardConnect.configure do |config|
          [:api_username, :api_password, :endpoint].each do |setting|
            value = Settings.cardconnect[setting].to_s.presence
            raise "Missing Settings.cardconnect.#{setting}" unless value
            config.public_send("#{setting}=", value)
          end
        end
      else
        if Rails.env.production? || Rails.env.staging?
          raise "CardConnect is not configured."
        else
          Rails.logger.warn "CardConnect is not configured"
        end
      end

      Facility.send(:include, NuCardconnect::FacilityExtensions)
      Statement.send(:include, NuCardconnect::StatementExtensions)
      Payment.valid_sources << :cardconnect
      ViewHook.add_hook("admin.shared.sidenav_admin", "last", "nu_cardconnect/merchant_accounts/sidebar_item")
      ViewHook.add_hook("notifier.statement", "end", "nu_cardconnect/notifier/statement")
    end

    initializer "nu_cardconnect.assets.precompile" do |app|
      app.config.assets.precompile += %w(cardconnect.js cardconnect.css)
    end
  end
end
