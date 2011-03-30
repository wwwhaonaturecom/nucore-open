require 'bcsec_authenticatable'
require 'bcdatabase/active_record/schema_qualified_tables'


Bcsec.configure do
  # The portal used to identify this app in
  # t_security_logins, t_security_applications, etc.
  portal 'nucore'
end


# Give Devise it's default auth strategy
Devise.setup do |devise_config|
  devise_config.warden do |manager|
    manager.default_strategies.unshift(:bcsec_authenticatable)
  end
end


config.after_initialize do
  # BCSec pers config
  unless Rails.env.production?
    pers_db=File.join(File.dirname(__FILE__), 'config', 'environments', "bcsec_#{Rails.env}.yml")

    ActiveRecord::Base.schemas = {
      :cc_pers => YAML::load(File.open(pers_db))['cc_pers']['user']
    }

    Bcsec.configure do
      # If using PersAuthenticator, set up the AR connection using the
      # central parameters file like so:
      #establish_cc_pers_connection
      pers_parameters :separate_connection => true

      # Provide one or more authenticators to use.
      # See doc/authenticators for more details
      authority :pers

      # Point to a bcsec central authentication parameters file for
      # cc_pers, netid LDAP, and policy values
      central File.join(File.dirname(__FILE__), 'config', 'environments', 'bcsec_development.yml')

      ui_mode :http_basic
      api_mode :http_basic
    end
  end
end


#
# For testing with local LDAP server
#

Bcsec::Authorities::Netid.class_eval do

  Bcsec::Authorities::Netid::LDAP_TO_BCSEC_ATTRIBUTE_MAPPING={
    :cn => :username,
    :sn => :last_name,
    :givenname => :first_name,
    :numiddlename => :middle_name,
    :title => :title,
    :mail => :email,
    :telephonenumber => :business_phone,
    :facsimiletelephonenumber => :fax,
    :employeenumber => :nu_employee_id
  }.collect { |ldap_attr, bcsec_attr|
    { :ldap => ldap_attr, :bcsec => bcsec_attr }
  }


  def find_by_criteria(ldap, *criteria)
    filter = criteria.collect { |c| create_criteria_filter(c) }.inject { |a, f| a | f }
    return [] unless filter
    base = "dc=tablexi,dc=com"
    ldap.search(:filter => filter, :base => base)
  end

end
