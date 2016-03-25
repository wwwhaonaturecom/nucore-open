set :deploy_to, "/home/nucore/nucore.northwestern.edu"
set :rails_env, "production"
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

server "nucore01.northwestern.edu", user: "nucore", roles: %w(web app db)
server "nucore02.northwestern.edu", user: "nucore", roles: %w(web app)

set :default_env, "LD_LIBRARY_PATH" => "/usr/lib/oracle/12.1/client64/lib",
                  "ORACLE_HOME" => "/usr/lib/oracle/12.1/client64/lib",
                  "NLS_LANG" => "AMERICAN_AMERICA.WE8MSWIN1252"

# Skylight is only used in production
set :linked_files, fetch(:linked_files, []).push("config/skylight.yml")
