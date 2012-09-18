module NewRelicUserExtension
  def error_details_hash
    {
      :id        => id,
      :email     => email,
      :username  => username,
      :full_name => full_name
    }
  end
end

module NewRelicExtensions
  extend ActiveSupport::Concern
  included do |base|
    before_filter :record_newrelic_custom_parameters
  end

  private

  # Send extra information to new relic
  def record_newrelic_custom_parameters
    options = {
      :user_agent => request.env['HTTP_USER_AGENT'],
      :ip_address => request.remote_ip
      # :cookies => cookies
    }

    # Send user information
    if current_user
      options.merge!({
        :user => current_user.error_details_hash
      })
    end

    if acting_as?
      options.merge!({
        :acting_as => acting_user.error_details_hash
        })
    end

    NewRelic::Agent.add_custom_parameters(options)

    true
  end

end

# Make sure the new relic gem is loaded
if defined?(NewRelic::Agent)

  Rails.application.config.to_prepare do
    User.send(:include, NewRelicUserExtension)
    ApplicationController.send(:include, NewRelicExtensions)
  end

end