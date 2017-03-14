server "nucore01s.northwestern.edu", user: "nucore", roles: %w(web app db)

set :deploy_to, "/home/nucore/nucore-staging.northwestern.edu"
set :rails_env, "stage"
set :branch, ENV["CIRCLE_SHA1"] || ENV["REVISION"] || ENV["BRANCH_NAME"] || "develop"

set :default_env, "LD_LIBRARY_PATH" => "/usr/lib/oracle/12.1/client64/lib",
                  "ORACLE_HOME" => "/usr/lib/oracle/12.1/client64/lib",
                  "NLS_LANG" => "AMERICAN_AMERICA.WE8MSWIN1252"
