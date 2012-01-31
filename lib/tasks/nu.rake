namespace :nu do

  desc 'update related to Task #32369'
  task :add_activity_01 => :environment do |t, args|
    NufsAccount.all.each do |nufs|
      validator=NucsValidator.new(nufs.account_number)
      next unless validator.project && validator.activity.nil?
      nufs.account_number=nufs.account_number.gsub("-#{validator.project}", "-#{validator.project}-01")
      nufs.save!
    end
  end


  desc 'fix related to Task #42921'
  task :strip_user_names => :environment do
    usernames=%w(dhj204 ewr045 jfs928 jlu920 jnl186 kanwar kse320 pnl857 rgg981 rgramsey rka671 roy056 tjl939 tvo vge206)
    users=User.arel_table

    usernames.each do |uname|
      usr=User.where(users[:username].matches("%#{uname}%")).first

      if usr
        usr.update_attribute :username, uname
      else
        puts "User with name #{uname} not found!"
      end
    end
  end


  desc 'fix related to Task #36727'
  task :provision_users => :environment do |t, args|
    # bcsec's ensuring to satisfy bcaudit on save is
    # handled in nucore by Bcaudit::Middleware which is
    # loaded at bcsec_authenticatable's initialization.
    # Since it's rack middleware, and therefore depends
    # on being a request-response cycle, it doesn't work
    # for tasks. Ideally there would be a bcsec-provided
    # mock to handle this, but there isn't, so overwrite
    # the method that ensures bcaudit satisfaction so that
    # this task can proceed.
    Pers::Base.class_eval %Q<
      protected

      def ensure_bcauditable
        Bcaudit::AuditInfo.current_user = Pers::Person.find_by_username('csi597')
      end
    >

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


  namespace :migrate do

    task :users, [:fake, :backtrace] => :environment do |t, args|
      @backtrace=args.backtrace
      @logger=Logger.new(File.open("#{Rails.root}/log/migration.log", 'w'))

      begin
        User.transaction do
          pid2uid, uname2usr={}, {}

          # Migrate users
          all_pers=Pers::Person.find(
            :all,
            :conditions => "t_security_logins.portal = 'nucore'",
            :joins => 'INNER JOIN t_security_logins ON t_security_logins.username = t_personnel.username'
          )

          all_pers.each do |per|
            usr=User.new(
              :email => per.email,
              :first_name => per.first_name,
              :last_name => per.last_name,
              :username => per.username
            )

            retried=false

            begin
              usr.save!
            rescue ActiveRecord::RecordInvalid
              raise if retried
              usr.email="user-#{per.personnel_id}@example.com"
              retried=true
              retry
            rescue => e
              log("Could not save Pers::Person #{per.username}, #{per.id}", e)
            else
              pid2uid[per.personnel_id]=usr.id
              uname2usr[usr.username]=usr
            end
          end

          assign_roles_and_permissions(uname2usr)
          update_foreign_keys(pid2uid)

          if args.fake
            log('Rolling back migration...')
            raise ActiveRecord::Rollback
          end
        end
      rescue => e
        log('Migration error', e)
      ensure
        @logger.close
      end
    end


    def log(msg, except=nil)
      if except
        msg += ": #{except.message}"
        msg += "\n#{except.backtrace.join("\n")}" if @backtrace
      end

      @logger.error(msg)
      puts msg
    end


    def assign_roles_and_permissions(name_to_user)
      all_operators=Pers::GroupMembership.find(
        :all,
        :conditions => { :portal => 'nucore' },
        :joins => 'INNER JOIN t_personnel ON t_security_group_members.username = t_personnel.username'
      )

      all_operators.each do |op|
        begin
          usr=name_to_user[op.username]
          raise "No user #{op.username} to grant permissions to! (GroupMembership #{op.id})" unless usr

          if op.group_name == UserRole::ADMINISTRATOR
            UserRole.grant(usr, UserRole::ADMINISTRATOR)
            next
          end

          affiliate_id=op.affiliate_id
          raise "User #{op.username} is a #{op.group_name} without facility! (GroupMembership #{op.id})" unless affiliate_id
          facility=Facility.find_by_pers_affiliate_id affiliate_id
          raise "Could not find facility with id #{affiliate_id}! (GroupMembership #{op.id})" unless facility

          case op.group_name
            when UserRole::FACILITY_DIRECTOR
              UserRole.grant(usr, UserRole::FACILITY_DIRECTOR, facility)
            when UserRole::FACILITY_ADMINISTRATOR
              UserRole.grant(usr, UserRole::FACILITY_ADMINISTRATOR, facility)
            when UserRole::FACILITY_STAFF
              UserRole.grant(usr, UserRole::FACILITY_STAFF, facility)
          end
        rescue => e
          log('Role/permission error', e)
        end
      end
    end


    def update_foreign_keys(personnel_to_user)
      cols2update=[ 'user_id', 'created_by', 'updated_by', 'deleted_by', 'approved_by', 'canceled_by', 'assigned_user_id' ]

      Dir["#{Rails.root}/app/models/*.rb"].each do |file_path|
        begin
          basename=File.basename(file_path, File.extname(file_path))
          clazz=basename.camelize.constantize
          next unless clazz.respond_to?(:column_names) && clazz.superclass == ActiveRecord::Base

          has_cols=clazz.column_names & cols2update
          next if has_cols.blank?
          
          clazz.all.each do |obj|
            has_cols.each do |col|
              personnel_id=obj[col.to_sym]

              if personnel_id.blank?
                log "Null value for #{col} on #{clazz.name} instance #{obj.id}. Next." if (col == 'created_by' || !col.end_with?('_by'))                
                next
              end

              uid=personnel_to_user[personnel_id]

              if uid.blank?
                if clazz == ProductUser
                  obj.destroy
                  break
                elsif clazz != UserPriceGroupMember && clazz != UserRole
                  log "No user id found for personnel_id #{personnel_id}! (#{clazz.name.tableize.singularize}##{col}). Next."
                end

                next
              end

              obj[col]=uid
              obj.save(false)                                         
            end
          end
        rescue => e
          log('FK update error', e)
        end
      end
    end

  end  
end
