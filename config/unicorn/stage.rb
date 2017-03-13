# env
env = ENV["RAILS_ENV"] || "stage"

# workers
worker_processes 2

# listen
listen "/tmp/unicorn-nucore-staging.northwestern.edu.socket", backlog: 64

# timeout
timeout 240

# preload
preload_app true

# paths
app_path = "/home/nucore/nucore-staging.northwestern.edu"
working_directory "#{app_path}/current"
pid               "tmp/pids/unicorn.pid"

# logging
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

# zero downtime
before_fork do |server, _worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |_, _|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end

before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = "#{app_path}/current/Gemfile"
end
