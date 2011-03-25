module Devise
  module Models
    module BcsecAuthenticatable

      def self.included(base)
        base.class_eval { attr_accessor :password }
      end


      def after_save
        ensure_login_record_exists
      end


      def ensure_login_record_exists
        login = Pers::Login.first(:conditions => { :portal => 'nucore', :username => username })
        Pers::Login.create(:portal_name => 'nucore', :username => username) unless login
      end

    end
  end
end