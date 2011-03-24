module Devise
  module Models
    module BcsecAuthenticatable

      def self.included(base)
        base.class_eval { attr_accessor :password }
      end


      def after_create
        login = Pers::Login.first(:conditions => { :portal => 'nucore', :username => username })
        Pers::Login.create(:portal_name => 'nucore', :username => username) unless login
      end

    end
  end
end