set :deploy_to, "/home/nucore/nucore-test.northwestern.edu"
set :rails_env, "stage"
set :branch, "develop"

server "nucore01s.northwestern.edu", user: "nucore", roles: %w(web app db)

set :default_env, {
  "LD_LIBRARY_PATH" => "/usr/lib/oracle/12.1/client64/lib",
  "ORACLE_HOME" => "/usr/lib/oracle/12.1/client64/lib"
}
