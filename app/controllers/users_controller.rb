class UsersController < ApplicationController
  admin_tab     :all
  before_filter :authenticate_user!
  before_filter :check_acting_as
  before_filter :init_current_facility

  load_and_authorize_resource

  layout 'two_column'

  def initialize 
    @active_tab = 'admin_users'
    super
  end

  # GET /facilities/:facility_id/users
  def index
    @users = current_facility.orders.find(:all, :conditions => ['ordered_at > ?', Time.zone.now - 1.year]).collect{|o| o.user}.uniq
    @users.delete nil # on a dev db with screwy data nil can get ya
    @users = @users.sort {|x,y| [x.last_name, x.first_name].join(' ') <=> [y.last_name, y.first_name].join(' ') }.paginate(:page => params[:page])
  end

  # GET /facilities/:facility_id/facility_users/new
  def new
    @user = User.new
  end

  # POST /facilities/:facility_id/facility_users
  def create
    @user   = User.new(params[:user])
    chars   = ("a".."z").to_a + ("1".."9").to_a + ("A".."Z").to_a
    newpass = Array.new(8, '').collect{chars[rand(chars.size)]}.join
    @user.password = newpass

    begin
      @user.save!
      flash[:notice] = 'The user was successfully created.'
      redirect_to facility_users_url
    rescue Exception => e
      @user.errors.add_to_base(e) if @user.errors.empty?
      render :action => "new" and return
    end

    # send email
    Notifier.deliver_new_user(:user => @user, :password => newpass)
  end

  def new_search
    return unless params[:username]
    user_attrs={ :username => params[:username].downcase }

    begin
      user = Pers::Person.find(:first, :conditions => ["LOWER(username) = ?", params[:username].downcase])

      if user
        user_attrs.merge!(:first_name => user.first_name, :last_name => user.last_name, :email => user.email)
      else
        user=NetidGateway.authority.find_users(params[:username].downcase).first
        raise "couldn't find user #{user_attrs[:username]}" unless user
        user_attrs.merge!(:first_name => user.first_name, :last_name => user.last_name, :email => user.email)
      end

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

  # POST /facilities/:facility_id/users/netid_search
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

  # GET /facilities/:facility_id/users/:user_id/switch_to
  def switch_to
    @user = User.find(params[:user_id])
    unless session_user.id == User.id
      session[:acting_user_id] = params[:user_id]
      session[:acting_ref_url] = facility_users_url
    end
    redirect_to facilities_path
  end

  def orders
  end

  def accounts
  end

  def show
  end
  
  def email
  end
end