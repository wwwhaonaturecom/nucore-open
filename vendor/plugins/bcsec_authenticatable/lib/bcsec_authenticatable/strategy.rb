require 'devise/strategies/base'

module Devise
  module Strategies
    class BcsecAuthenticatable < Base

      def authenticate!
        return succeed_authentication(params[:username]) if  Bcsec.authority.auth_disabled?
        return fail(:invalid) if params[:username].blank? || params[:password].blank?

        # Must set these attribues for Bcaudit otherwise a "No audit info available.
        # Please configure Bcaudit before saving." error will pop up on credential checking
        Bcaudit::AuditInfo.current_ip=request.remote_ip
        user = Bcsec.authority.valid_credentials?(:user, params[:username], params[:password])

        unless user
          fail(:unauthenticated)
        else
          succeed_authentication(user.username)
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
