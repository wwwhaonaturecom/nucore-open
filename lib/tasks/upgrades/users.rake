namespace :users do
  task :downcase_usernames => :environment do
    User.update_all("username = lower(username)")
  end

  desc 'list all external users'
  task :list_external => :environment do
    puts "Username|First Name|Last Name|Email"
    User.where("username like '%@%'").each do |user|
      puts "#{user.username},#{user.first_name}|#{user.last_name}|#{user.email}"
    end
  end
end
