module SearchControllerExtension

  def user_search_results
    raise NUCore::PermissionDenied unless session_user
    @limit       = 25
    @facility    = Facility.find(params[:facility_id]) if params[:facility_id]
    @price_group = PriceGroup.find(params[:price_group_id]) if params[:price_group_id]
    @account     = Account.find(params[:account_id]) if params[:account_id]
    @product     = Product.find(params[:product_id]) if params[:product_id]

    term = generate_multipart_like_search_term(params[:search_term])
    if params[:search_term].length > 0
      conditions = ["(LOWER(t_personnel.first_name) LIKE ? OR LOWER(t_personnel.last_name) LIKE ? OR LOWER(t_personnel.username) LIKE ? OR LOWER(CONCAT(t_personnel.first_name, t_personnel.last_name)) LIKE ?) AND t_security_logins.portal = ?",
                    term, term, term, term, NUCore.portal]
      @users = Pers::Person.find(:all, :conditions => conditions, :order => "last_name, first_name", :joins => 'INNER JOIN t_security_logins ON t_security_logins.username = t_personnel.username', :limit => @limit)
      @count = Pers::Person.count(:all, :conditions => conditions, :joins => 'INNER JOIN t_security_logins ON t_security_logins.username = t_personnel.username')
    end
    render :layout => false
  end

end