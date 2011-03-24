require 'devise'
require 'bcsec_authenticatable/strategy'
require 'bcsec_authenticatable/routes'

Devise.add_module(
  :bcsec_authenticatable,
  :strategy => true,
  :controller => :sessions,
  :model => 'bcsec_authenticatable/model'
)
