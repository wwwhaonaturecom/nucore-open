require 'bcsec_authenticatable'
require 'bcdatabase/active_record/schema_qualified_tables'


# Give Devise it's default auth strategy
Devise.setup do |devise_config|
  devise_config.warden do |manager|
    manager.default_strategies.unshift(:bcsec_authenticatable)
  end
end


config.after_initialize do
  Bcsec.configure do

    # The portal used to identify this app in
    # t_security_logins, t_security_applications, etc.
    portal 'nucore'

    # BCSec pers config
    unless Rails.env.production?
      auth_file=File.join(File.dirname(__FILE__), 'config', 'environments', "bcsec_#{Rails.env}.yml")
      auth_yaml=YAML::load(File.open(auth_file))

      # Point to a bcsec central authentication parameters file for
      # cc_pers, netid LDAP, and policy values
      central auth_file

      # Configure pers
      pers_parameters :separate_connection => true
      ActiveRecord::Base.schemas = { :cc_pers => auth_yaml['cc_pers']['user'] }

      # Configure authorities
      auths=[ :pers ]

      unless Rails.env.test?
        # Configure netid
        netid_conf={}
        auth_yaml['netid'].each{|k,v| netid_conf[k.to_sym]=v }
        auths << Bcsec::Authorities::Netid.new(netid_conf)
      end

      authorities(*auths)

      ui_mode :http_basic
      api_mode :http_basic
    end

  end

  # The bcsec version of #current_user inteferes with (overwrites?)
  # Devise's version. Duplicate the Devise version here to ensure it is used.
  ApplicationController.class_eval do
    def current_user
      @current_user ||= warden.authenticate(:scope => :user)
    end
  end
end


# Make it easy to access the configured authorities
Bcsec::Authorities::Composite.class_eval do

  def pers
    authorities[0]
  end

  def netid
    authorities[1]
  end

end


#
# For testing with local LDAP server
#

#Bcsec::Authorities::Netid.class_eval do
#
#  Bcsec::Authorities::Netid::LDAP_TO_BCSEC_ATTRIBUTE_MAPPING={
#    :cn => :username,
#    :sn => :last_name,
#    :givenname => :first_name,
#    :numiddlename => :middle_name,
#    :title => :title,
#    :mail => :email,
#    :telephonenumber => :business_phone,
#    :facsimiletelephonenumber => :fax,
#    :employeenumber => :nu_employee_id
#  }.collect { |ldap_attr, bcsec_attr|
#    { :ldap => ldap_attr, :bcsec => bcsec_attr }
#  }
#
#
#  def find_by_criteria(ldap, *criteria)
#    filter = criteria.collect { |c| create_criteria_filter(c) }.inject { |a, f| a | f }
#    return [] unless filter
#    base = "dc=tablexi,dc=com"
#    ldap.search(:filter => filter, :base => base)
#  end
#
#end
