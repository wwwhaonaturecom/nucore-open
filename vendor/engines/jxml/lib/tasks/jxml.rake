namespace :jxml do

  desc <<-DOC
    imports a set of dates from a plain ol' text file. The file should have
    one date per line. Each date should be formatted as 'YYYY-MM-DD'. For example:
       ...
    2013-05-27
    2013-07-04
    2013-09-02
    2013-11-28
       ...
  DOC
  task :import, [:path_to_file] => :environment do |t, args|
    JxmlHoliday.import args.path_to_file
  end


  desc 'meets needs of Task #32337'
  task :render_and_move, [:render_dir, :move_dir] => :environment do |t, args|
    JxmlRenderer.render args.render_dir, args.move_dir
  end

end
