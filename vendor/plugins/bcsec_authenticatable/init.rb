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
    if Rails.env.development? || Rails.env.test?
      auth_file=File.join(File.dirname(__FILE__), 'config', 'environments', "bcsec_#{Rails.env}.yml")
    else
      auth_file=File.join('/', 'etc', 'nubic', 'bcsec-prod.yml')
    end

    auth_yaml=YAML::load(File.open(auth_file))

    # Point to a bcsec central authentication parameters file for
    # cc_pers, netid LDAP, and policy values
    central auth_file

    # Configure pers
    pers_usr=auth_yaml['cc_pers']['user']
    pers_usr='cc_pers' if pers_usr.blank?

    pers_parameters :separate_connection => true
    ActiveRecord::Base.schemas = { :cc_pers => pers_usr }

    # Configure authorities
    auths=[ :pers ]

    case Rails.env
      when 'test'
      when 'development'
        if auth_yaml['netid']
          netid_conf={}
          auth_yaml['netid'].each{|k,v| netid_conf[k.to_sym]=v }
          auths << Bcsec::Authorities::Netid.new(netid_conf)
        end
      else
        auths << :netid
    end

    authorities(*auths)

    ui_mode :http_basic
    api_mode :http_basic
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

  @@auth_yaml=nil

  if Rails.env.development?
    auth_file=File.join(File.dirname(__FILE__), 'config', 'environments', "bcsec_#{Rails.env}.yml")
    @@auth_yaml=YAML::load(File.open(auth_file))
  end

  def pers
    authorities[0]
  end

  def netid
    authorities[1]
  end

  def auth_disabled?
    @@auth_yaml && @@auth_yaml['policy']['disable_authentication']
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
#  protected
#
#  def create_user(ldap_entry)
#    Bcsec::User.new(one_value(ldap_entry, :uid)).tap do |u|
#      # directly mappable attrs
#      Bcsec::Authorities::Netid::LDAP_TO_BCSEC_ATTRIBUTE_MAPPING.collect { |map|
#        [map[:ldap], :"#{map[:bcsec]}="]
#      }.each do |ldap_attr, user_setter|
#        u.send user_setter, one_value(ldap_entry, ldap_attr)
#      end
#      u.username='fstump'
#
#      # more fiddly ones
#      u.city, u.address =
#        extract_address_elements(one_value(ldap_entry, :postaladdress))
#    end
#  end
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
