module UsersControllerExtension

  def new_search
    return unless params[:username]
    user_attrs={ :username => params[:username].downcase }

    begin
      user = Pers::Person.find(:first, :conditions => ["LOWER(username) = ?", params[:username].downcase])
      user=NetidGateway.authority.find_users(params[:username].downcase).first unless user
      raise "couldn't find user #{user_attrs[:username]}" unless user
      user_attrs.merge!(:first_name => user.first_name, :last_name => user.last_name, :email => user.email)
      @user=User.find_or_create_by_username(user_attrs)
      @user.ensure_login_record_exists
      Notifier.deliver_new_user(:user => @user, :password => nil)
    rescue => e
      Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")
      flash[:error] = 'An error was encountered while attempting to add the user.'
      redirect_to new_search_facility_users_url(current_facility) and return
    end

    flash[:notice] = "The user has been added successfully."

    if session_user.manager_of?(current_facility)
      flash[:notice] += "  You may wish to <a href=\"#{facility_facility_user_map_user_url(current_facility, user.personnel_id)}\">add a facility role</a> for this user."
    end

    redirect_to facility_users_url(current_facility)
  end


  def username_search
    # look up username in cc_pers
    @user = Pers::Person.find(:first, :conditions => ["LOWER(username) = ?", params[:username_lookup].downcase])

    if @user.nil? && (params[:has_netid] == 'yes')
      begin
        @user=NetidGateway.authority.find_users(params[:username_lookup].downcase).first
        @user.username=params[:username_lookup].downcase if @user # because Bcsec::Authorities::Netid#create_user intentionally excludes the username
      rescue => e
        Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")
      end
    end

    render :layout => false
  end

end