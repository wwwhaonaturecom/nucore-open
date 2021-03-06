require "saml_authentication/user_locator"
require "saml_authentication/user_updater"

module SamlAuthentication

  class DeviseConfigurator

    def configure!
      Devise.setup do |config|
        config.saml_session_index_key = :session_index
        config.saml_default_user_key = :username
        config.saml_create_user = true
        config.saml_update_user = true
        config.saml_resource_locator = SamlAuthentication::UserLocator.new
        config.saml_update_resource_hook = SamlAuthentication::UserUpdater.new

        config.saml_config = fetch_metadata_config

        config.saml_configure do |settings|
          settings.assertion_consumer_service_url = Rails.application.routes.url_helpers.auth_saml_user_session_url
          settings.issuer = Rails.application.routes.url_helpers.metadata_saml_user_session_url

          configure_security(settings)
        end
      end
    end

    private

    def fetch_metadata_config
      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      # Can be either remote or local
      if Settings.saml.idp_metadata.start_with?("https://")
        idp_metadata_parser.parse_remote(Settings.saml.idp_metadata, true)
      else
        idp_metadata_parser.parse(File.open(File.expand_path(Settings.saml.idp_metadata)))
      end
    end

    def configure_security(settings)
      if Settings.saml.certificate_file
        pkcs12 = OpenSSL::PKCS12.new(File.read(File.expand_path(Settings.saml.certificate_file)))
        settings.certificate = pkcs12.certificate.to_s
        settings.private_key = pkcs12.key.to_s
      end

      settings.security[:authn_requests_signed] = true
      settings.security[:logout_requests_signed] = true
      settings.security[:logout_responses_signed] = true
      settings.security[:want_assertions_signed] = true
      settings.security[:metadata_signed] = true

      settings.security[:digest_method] = XMLSecurity::Document::SHA256
      settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256
    end

  end

end
