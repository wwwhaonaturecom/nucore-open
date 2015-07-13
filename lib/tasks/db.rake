namespace :db do
  def db_allow_task?
    if Rails.env.test? || Rails.env.development?
      true
    else
      puts "Only allowed in development and test mode"
      false
    end
  end

  desc "Drop database for current RAILS_ENV"
  task :oracle_drop => :environment do
    next unless db_allow_task?
    config= Rails.configuration.database_configuration[Rails.env]
    connect_string = "#{config["username"]}/#{config["password"]}@#{config["database"]}"
    system "bash -lc 'cd #{Rails.root}/db && ./generate_drops.sh | sqlplus #{connect_string}'"
  end

  desc "Load the schema from structure.sql"
  task :oracle_load => :environment do
    config= Rails.configuration.database_configuration[Rails.env]
    connect_string = "#{config["username"]}/#{config["password"]}@#{config["database"]}"
    system "bash -lc 'cd #{Rails.root}/db && sqlplus #{connect_string} < structure.sql'"
  end

  desc "Remove the DMRS tables from a production DB dump"
  task :drop_dmrs => :environment do
    next unless db_allow_task?

    table_names = ActiveRecord::Base.connection.select_rows(
      "select table_name from all_tables where table_name like 'DMRS_%'").map(&:first)
    table_names.each do |table|
      command = "drop table #{table}"
      puts command
      ActiveRecord::Base.connection.execute(command)
    end
  end
end
