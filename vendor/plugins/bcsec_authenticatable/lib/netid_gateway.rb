#
# Encapsulates Netid (LDAP) server access
module NetidGateway

  mattr_reader :authority

  #
  # Replace these credentials with real ones.
  # Probably best not to hard code with plain-text.
  @@authority=Bcsec::Authorities::Netid.new({
    :server => 'localhost',
    :port => 389,
    :user => 'cn=admin,dc=tablexi,dc=com',
    :password => 'secret',
    :use_tls => false
   })

end