require 'devise/strategies/base'

module Devise
  module Strategies
    class BcsecAuthenticatable < Base

      def authenticate!
        return succeed_authentication(params[:username]) if  Bcsec.authority.auth_disabled?
        return fail(:unauthenticated) unless params[:username] && params[:password] && request.post?
        return fail(:invalid) if params[:username].blank? || params[:password].blank?

        begin
          user = Bcsec.authority.valid_credentials?(:user, params[:username], params[:password])
        rescue Errno::ETIMEDOUT => e
          user=nil
          Rails.logger.error "TIMEOUT received when authenticating user: #{e.message}"
        end

        if user
          succeed_authentication(user.username)
        else
          fail(:invalid)
        end
      end


      private

      def succeed_authentication(username)
        nucore_user=User.find_by_username username
        success!(nucore_user)
      end

    end
  end
end

Warden::Strategies.add(:bcsec_authenticatable, Devise::Strategies::BcsecAuthenticatable)
