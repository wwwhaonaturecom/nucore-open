require 'devise/strategies/base'

module Devise
  module Strategies
    class BcsecAuthenticatable < Base

      def authenticate!
        user = Bcsec.authority.valid_credentials?(:user, params[:username], params[:password])

        unless user
          fail(:invalid)
        else
          nucore_user=User.find_by_username user.username
          success!(nucore_user)
        end
      end

    end
  end
end

Warden::Strategies.add(:bcsec_authenticatable, Devise::Strategies::BcsecAuthenticatable)
