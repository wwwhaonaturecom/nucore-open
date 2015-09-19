# Add your fork-specific cron jobs here
# This file is automatically included by schedule.rb

every :day, at: '7:20am' do
  rake 'nucs:import:all[$HOME/files/FFRA-in/current]'
end

every :day, at: '7:40am' do
  rake 'chart_strings:update_expiration'
end

if @environment == "production"
  every :day, at: '5:15pm' do
    rake 'jxml:render_and_move[$HOME/nucore.northwestern.edu/shared/journals,$HOME/files/FFRA-out/current]'
  end
end

every :day, at: '7:00am' do
  rake 'pmu:import'
end
