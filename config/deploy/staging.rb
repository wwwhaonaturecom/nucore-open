set :deploy_to, "/home/nucore/nucore-staging.nubic.northwestern.edu"
set :rails_env, "staging"
set :branch, "develop"

server "nucore01s.northwestern.edu", user: "nucore", roles: %w(web app db)

set :default_env {
  "LD_LIBRARY_PATH" => "/usr/lib/oracle/11.2/client64/lib",
  "ORACLE_HOME" => "/usr/lib/oracle/11.2/client64/lib"
}
