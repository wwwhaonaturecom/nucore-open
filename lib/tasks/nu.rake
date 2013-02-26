namespace :nu do

  desc 'find orders that should have received cancer center pricing'
  task :find_cancer_center_order_details => :environment do |t, args|
    import DateHelper

    cancer_center_group = PriceGroup.find(2)
    start_date = Time.zone.parse('09/01/12').beginning_of_day
    order_details = OrderDetail.where(:state => ['complete']).where('fulfilled_at > ?', start_date).where('price_policy_id IS NOT NULL')

    puts "Total orders completed in September: #{order_details.count}"

    order_details.each_with_index do |od, i|
      original_cost = od.actual_cost
      original_subsidy = od.actual_subsidy
      original_price_policy = od.price_policy
      original_group = od.price_policy.price_group.name
      od.assign_price_policy
      # assign price policy only updates id
      od.price_policy = PricePolicy.find(od.price_policy_id)
      if od.price_policy.price_group_id == cancer_center_group.id && od.price_policy != original_price_policy
        if [23269,26291, 26172, 26480].include? od.id
          od.actual_cost = original_cost
          od.actual_subsidy = original_subsidy
        end
        puts "#{od}, #{od.fulfilled_at}, #{od.facility}, #{od.product}, #{od.account}, #{od.account.owner.user.name}, #{original_group}, #{original_cost}, #{original_subsidy}, #{od.price_policy.price_group.name}, #{od.actual_cost}, #{od.actual_subsidy}"
        od.save!
      end
    end
    puts "Done"
  end

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


  desc 'fix for task #59917'
  task :update_pathcore_orders => :environment do
    old_purchaser = User.find_by_email 'l-esker@northwestern.edu'
    new_purchaser = User.find_by_email 'pathology.core@gmail.com'
    facility = Facility.find_by_url_name 'path'
    order_details = facility.order_details.where("state = 'complete'").all

    File.open(File.join(Rails.root, 'tmp', 'pathcore.csv'), 'w+') do |csv|
      csv << "Order #,Status,Account,User,Product,Fulfilled at,Old price group,Old cost,Old subsidy,Old total,New price group,New cost,New subsidy,New total,Changed?\n"

      order_details.each do |od|
        if od.price_policy.nil?
          puts "Order detail ##{od.to_s} does not have a price policy"
          next
        end

        detail = []

        if od.order.user == old_purchaser
          od.order.user = new_purchaser
          od.order.save!
        end

        pg = od.price_policy.price_group.name
        cost = od.actual_cost
        subsidy = od.actual_subsidy
        total = od.actual_total

        detail += [
          od.to_s,
          od.state,
          od.account.account_number,
          "\"#{od.order.user.to_s}\"",
          "\"#{od.product.name}\"",
          od.fulfilled_at,
          pg,
          cost,
          subsidy,
          total
        ]

        od.price_policy = nil
        od.assign_price_policy
        od.save!

        new_pg = od.price_policy.price_group.name
        new_cost = od.actual_cost
        new_subsidy = od.actual_subsidy
        new_total = od.actual_total
        od_changed = (pg != new_pg || cost != new_cost || subsidy != new_subsidy || total != new_total)

        detail += [ new_pg, new_cost, new_subsidy, new_total, od_changed ]
        csv << detail.join(',') + "\n"
      end
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
