module Devise
  module Models
    module BcsecAuthenticatable

      def self.included(base)
        base.class_eval { attr_accessor :password }
      end


      def after_create
        raise 'could not create pers record' unless Pers::Person.find_or_create_by_username({
          :first_name => first_name,
          :last_name => last_name,
          :email => email,
          :username => username,
          :entered_date => Time.zone.now,
          :plain_text_password => password
        })
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