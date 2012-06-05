namespace :nu do

  desc 'order updates for task #46319'
  task :update_order_details_46319 => :environment do |t, args|
    od_to_price={
      7624 => 90.0,
      7901 => 25.50,
      8939 => 7.40,
      7757 => 69.60
    }

    od_to_price.each do |od_id, actual|
      od=OrderDetail.find od_id
      od.update_attributes :actual_cost => actual, :actual_subsidy => 0
    end
  end


  desc 'update related to Task #32369'
  task :add_activity_01 => :environment do |t, args|
    NufsAccount.all.each do |nufs|
      validator=NucsValidator.new(nufs.account_number)
      next unless validator.project && validator.activity.nil?
      nufs.account_number=nufs.account_number.gsub("-#{validator.project}", "-#{validator.project}-01")
      nufs.save!
    end
  end


  desc 'fix related to Bug #44115'
  task :correct_auto_cancelled_orders => :environment do |t, args|
    order_detail_ids=[ 6919, 6920, 6912, 6913, 6914, 6915, 6924, 6929, 6930, 6911, 6916, 6923, 6928, 6925, 6922, 6917 ]
    complete=OrderStatus.complete.first

    order_detail_ids.each do |odid|
      begin
        od=OrderDetail.find odid
        reservation=od.reservation
        od.change_status! complete unless od.order_status == complete || od.order_status.parent_id == complete.id

        reservation.update_attributes!(
          :canceled_by => nil,
          :canceled_at => nil,
          :canceled_reason => nil,
          :actual_start_at => reservation.reserve_start_at,
          :actual_end_at => reservation.reserve_end_at
        )

        od.assign_price_policy
        od.save!
      rescue => e
        puts "Could not fix order detail with id #{odid}!: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end


  desc 'fix related to Task #42921'
  task :strip_user_names => :environment do
    appease_bcaudit

    usernames=%w(dhj204 ewr045 jfs928 jlu920 jnl186 kanwar kse320 pnl857 rgg981 rgramsey rka671 roy056 tjl939 tvo vge206)

    usernames.each do |uname|
      puts "Looking for #{uname}.."
      usr=User.where(:username => "\t#{uname}").first

      if usr
        puts "Found [#{usr.username}]"
        usr.username=usr.username.strip
        puts "Could not save [#{usr.username}]: #{usr.errors.full_messages.join("\n")}" unless usr.save
      else
        puts "User with name #{uname} not found!"
      end
    end
  end


  desc 'fix related to Task #36727'
  task :provision_users => :environment do |t, args|
    appease_bcaudit

    User.all.each do |user|
      if Pers::Person.find_by_username(user.username).nil?
        password=nil

        if user.external?
          chars=("a".."z").to_a + ("1".."9").to_a + ("A".."Z").to_a
          password=Array.new(8, '').collect{chars[rand(chars.size)]}.join
        end

        Pers::Person.create!({
          :first_name => user.first_name,
          :last_name => user.last_name,
          :email => user.email,
          :username => user.username,
          :entered_date => Time.zone.now,
          :plain_text_password => password
        })

        Notifier.new_user(:user => user, :password => password).deliver if user.external?
      end

      if Pers::Login.first(:conditions => {:portal => 'nucore', :username => user.username}).nil?
        Pers::Login.create!(:portal_name => 'nucore', :username => user.username)
      end
    end
  end


  desc 'fix for task #44731'
  task :remove_mhpl_orders => :environment do |t,args|
    order_ids=[]
    ids=%w(619-308 623-319 623-320 619-307 622-317 622-318 622-315 622-316 621-311 621-312 621-313 621-314 621-310 620-309 618-306 618-305 618-303 618-304)

    ids.each do |id|
      oids=id.split('-')
      order_ids << oids[0].to_i
      order_detail_id=oids[1].to_i

      begin
        od=OrderDetail.find(order_detail_id)
        od.destroy
        puts "Destroyed order detail #{order_detail_id} of #{id}"
      rescue ActiveRecord::RecordNotFound
        puts "Order detail #{order_detail_id} not found"
      end
    end

    order_ids.uniq.each do |id|
      begin
        order=Order.find id

        if order.order_details.empty?
          order.destroy
          puts "Destroyed order #{id}"
        end
      rescue ActiveRecord::RecordNotFound
        puts "Order #{id} not found"
      end
    end
  end


  desc 'fix for task #47959'
  task :update_relays_47959 => :environment do
    relays=Relay.where("type LIKE 'RelaySynaccessRev%' AND ip IS NULL AND port IS NULL").all
    relays.each {|relay| relay.destroy }
  end

  
  namespace :journal do

    desc 'meets needs of Task #32337'
    task :render_and_move, [:render_dir, :move_dir] => :environment do |t, args|
      # needed to humanize dates/datetimes
      include ApplicationHelper
      from_dir, to_dir=args.render_dir, args.move_dir
      raise 'Must specify a directory to render in and a directory to move to' unless from_dir && to_dir

      today=Date.today.to_s
      window_date=Time.zone.parse("#{today} 17:00:00")
      journals=Journal.where('created_at >= ? AND created_at < ? AND is_successful IS NULL', window_date-1.day, window_date).all

      next if journals.empty? # break out the task
      xml_name="#{today.gsub(/-/,'')}_CCC_UPLOAD.XML"
      xml_src=File.join(from_dir, xml_name)
      xml_dest=File.join(to_dir, xml_name)
      
      av=ActionView::Base.new(Rails.application.config.view_path)
      File.open(xml_src, 'w') do |xml|
        journals.each do |journal|
          # props to http://www.omninerd.com/articles/render_to_string_in_Rails_Models_or_Rake_Tasks
          xml << av.render(:partial => 'facility_journals/rake_show.xml.haml', :locals => { :journal => journal, :journal_rows => journal.journal_rows })
          puts av.render(:partial => 'facility_journals/rake_show.text.haml', :locals => {:journal => journal})
          puts
        end
      end

      FileUtils.mv(xml_src, xml_dest)
    end

  end


  #
  # bcsec's ensuring to satisfy bcaudit on save is
  # handled in nucore by Bcaudit::Middleware which is
  # loaded at bcsec_authenticatable's initialization.
  # Since it's rack middleware, and therefore depends
  # on being a request-response cycle, it doesn't work
  # for tasks. Ideally there would be a bcsec-provided
  # mock to handle this, but there isn't, so overwrite
  # the method that ensures bcaudit satisfaction so that
  # this task can proceed.
  def appease_bcaudit(username='csi597')
    Pers::Base.class_eval %Q<
      protected

      def ensure_bcauditable
        Bcaudit::AuditInfo.current_user = Pers::Person.find_by_username('#{username}')
      end
    >
  end

end
