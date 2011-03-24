ActionController::Routing::RouteSet::Mapper.class_eval do

  protected
    # reuse the session routes and controller
    alias :bcsec_authenticatable :database_authenticatable
end