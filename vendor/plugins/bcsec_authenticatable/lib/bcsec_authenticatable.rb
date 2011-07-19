require 'devise'
require 'bcsec_authenticatable/strategy'

Devise.add_module(
  :bcsec_authenticatable,
  :route => :session, ## This will add the routes, rather than in the routes.rb
  :strategy => true,
  :controller => :sessions,
  :model => 'bcsec_authenticatable/model'
)
