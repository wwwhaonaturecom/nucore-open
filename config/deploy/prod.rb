set :deploy_to, "/home/nucore/nucore.northwestern.edu"
set :rails_env, "production"
set :branch, "master"

server "nucore01.northwestern.edu", user: "nucore", roles: %w(web app db)
server "nucore02.northwestern.edu", user: "nucore", roles: %w(web app)

set :default_env, {
  "LD_LIBRARY_PATH" => "/usr/lib/oracle/12.1/client64/lib",
  "ORACLE_HOME" => "/usr/lib/oracle/12.1/client64/lib",
  "NLS_LANG" => "AMERICAN_AMERICA.WE8MSWIN1252"
}
