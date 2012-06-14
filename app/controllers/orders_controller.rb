class OrdersController < ApplicationController
  customer_tab  :all

  before_filter :authenticate_user!
  before_filter :check_acting_as,          :except => [:cart, :add, :choose_account, :show, :remove, :purchase, :receipt, :update]
  before_filter :init_order,               :except => [:cart, :index, :receipt]
  before_filter :protect_purchased_orders, :except => [:cart, :receipt, :confirmed, :index]

  def initialize
    @active_tab = 'orders'
    super
  end

  def init_order
    @order = Order.find(params[:id])
  end

  def protect_purchased_orders
    if @order.state == 'purchased'
      redirect_to receipt_order_url(@order) and return
    end
  end

  # GET /orders/cart
  def cart
    @order = acting_user.cart(session_user)
    redirect_to order_path(@order) and return
  end

  # GET /orders/:id
  def show
    @order.validate_order! if @order.new?
  end

  # PUT /orders/:id/update
  def update
    order_detail_updates = {}
    params.each do |key, value|
      if /^(quantity|note)(\d+)$/ =~ key and value.present?
        order_detail_updates[$2.to_i] ||= Hash.new
        order_detail_updates[$2.to_i][$1.to_sym] = value
      end
    end
    @order.update_details(order_detail_updates)

    redirect_to order_path(@order) and return
  end

  # PUT /orders/:id/clear
  def clear
    @order.clear!
    redirect_to order_path(@order) and return
  end

  # GET /orders/2/add/
  # PUT /orders/2/add/
  def add
    ## get items to add from the form post or from the session
    ods_from_params = (params[:order].presence and params[:order][:order_details].presence) || []
    items =  ods_from_params.presence || session[:add_to_cart].presence || []
    session[:add_to_cart] = nil


    # ignore ods w/ empty or 0 quantities
    items = items.select { |od| od.is_a?(Hash) and od[:quantity].present? and (od[:quantity] = od[:quantity].to_i) > 0 }
    return redirect_to(:back, :notice => "Please add at least one quantity to order something") unless items.size > 0

    first_product = Product.find(items.first[:product_id])
    facility_ability = Ability.new(session_user, first_product.facility, self)

    # if acting_as, make sure the session user can place orders for the facility
    if acting_as? && facility_ability.cannot?(:act_as, first_product.facility)
      flash[:error] = "You are not authorized to place an order on behalf of another user for the facility #{current_facility.try(:name)}."
      redirect_to order_url(@order) and return
    end



    ## handle a single instrument reservation
    if items.size == 1 and (quantity = items.first[:quantity].to_i) == 1 #only one od w/ quantity of 1
      if first_product.respond_to?(:reservations)                              # and product is reservable
        
        # make a new cart w/ instrument (unless this order is empty.. then use that one)
        @order = acting_user.cart(session_user, @order.order_details.empty?)
        @order.add(first_product, 1)

        # bypass cart kicking user over to new reservation screen
        return redirect_to new_order_order_detail_reservation_url(@order.id, @order.order_details.first)
      end
    end

    ## make sure the order has an account
    if @order.account.nil?
      begin
        @order.auto_assign_account!(@product)
      rescue => e
        flash[:error]=e.message
        session[:add_to_cart] = items
        redirect_to choose_account_order_url(@order) and return
      end
    end

    ## process each item
    @order.transaction do
      items.each do |item|
        @product = Product.find(item[:product_id])
        begin
          @order.add(@product, item[:quantity])
          @order.invalidate! ## this is because we just added an order_detail
        rescue NUCore::MixedFacilityCart
          @order.errors.add(:base, "You can not add a product from another facility; please clear your cart or place a separate order.")
        rescue Exception => e
          @order.errors.add(:base, "An error was encountered while adding the product #{@product}.")
          Rails.logger.error(e.backtrace.join("\n"))
        end
      end

      if @order.errors.any?
        flash[:error] = "There were errors adding to your cart:<br>"+@order.errors.full_messages.join('<br>').html_safe
        raise ActiveRecord::Rollback
      end
    end

    redirect_to order_url(@order)
  end

  # PUT /orders/:id/remove/:order_detail_id
  def remove
    order_detail = @order.order_details.find(params[:order_detail_id])

    # remove bundles
    if order_detail.group_id
      order_details = @order.order_details.find(:all, :conditions => {:group_id => order_detail.group_id})
      OrderDetail.transaction do
        if order_details.all?{|od| od.destroy}
          flash[:notice] = "The bundle has been removed."
        else
          flash[:error] = "An error was encountered while removing the bundle."
        end
      end
    # remove single products
    else
      if order_detail.destroy
        flash[:notice] = "The product has been removed."
      else
        flash[:error] = "An error was encountered while removing the product."
      end
    end

    redirect_to params[:redirect_to].presence || order_url(@order)

    # clear out account on the order if its now empty
    if  @order.order_details.empty?
      @order.account_id = nil
      @order.save!
    end
  end

  # GET  /orders/:id/choose_account
  # POST /orders/:id/choose_account
  def choose_account
    if request.post?
      begin
        account = Account.find(params[:account_id])
        raise ActiveRecord::RecordNotFound unless account.can_be_used_by?(@order.user)
      rescue
      end
      if account
        success = true
        @order.transaction do
          begin
            @order.invalidate
            @order.update_attributes!(:account_id => account.id)
            @order.update_order_detail_accounts
          rescue Exception => e
            success = false
            raise ActiveRecord::Rollback
          end
        end
      end

      if success
        if session[:add_to_cart].nil?
          redirect_to cart_url
        else
          redirect_to add_order_url(@order)
        end
        return
      else
        flash.now[:error] = account.nil? ? 'Please select a payment method.' : 'An error was encountered while selecting a payment method.'
      end
    end

    if params[:reset_account]
      @order.order_details.each do |od|
        od.account = nil
        od.save!
      end
    end

    if session[:add_to_cart].blank?
      @product = @order.order_details[0].product
    else
      @product = Product.find(session[:add_to_cart].first[:product_id])
    end
    @accounts = acting_user.accounts.for_facility(@product.facility).active
    @errors   = {}
    details   = @order.order_details
    @accounts.each do |account|
      if session[:add_to_cart] and
         ods = session[:add_to_cart].presence and
         product_id = ods.first[:product_id]
        error = account.validate_against_product(Product.find(product_id), acting_user)
        @errors[account.id] = error if error
      end
      unless @errors[account.id]
        details.each do |od|
          error = account.validate_against_product(od.product, acting_user)
          @errors[account.id] = error if error
        end
      end
    end
  end

  def add_account
    flash.now[:notice] = "This page is still in development; please add an account administratively"
  end

  # PUT /orders/1/purchase
  def purchase
    #revalidate the cart, but only if the user is not an admin
    @order.being_purchased_by_admin = session_user.operator_of? @order.facility
    if @order.validate_order! && @order.purchase!
      Notifier.order_receipt(:user => @order.user, :order => @order).deliver

      if @order.order_details.size == 1 && @order.order_details[0].product.is_a?(Instrument) && !@order.order_details[0].bundled?
        od=@order.order_details[0]

        if od.reservation.can_switch_instrument_on?
          redirect_to order_order_detail_reservation_switch_instrument_path(@order, od, od.reservation, :switch => 'on', :redirect_to => reservations_path)
        else
          redirect_to reservations_path
        end

        flash[:notice]='Reservation completed successfully'
      else
        redirect_to receipt_order_url(@order)
      end

      return
    else
      flash[:error] = 'Unable to place order.'
      @order.invalidate!
      redirect_to order_url(@order) and return
    end
  end

  # GET /orders/1/receipt
  def receipt
    @order = Order.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @order.purchased?

    @order_details = @order.order_details.select{|od| od.can_be_viewed_by?(acting_user) }
    raise ActiveRecord::RecordNotFound if @order_details.empty?

    @accounts = @order_details.collect(&:account)
  end

  # GET /orders
  # all my orders
  def index
    # new or in process
    @order_details = session_user.order_details.non_reservations
    @available_statuses = ['pending', 'all']
    case params[:status]
    when "pending"
      @order_details = @order_details.pending
    when "all"
      @order_details = @order_details.ordered
    else
      redirect_to orders_status_path(:status => "pending")
      return
    end
    @order_details = @order_details. order('order_details.created_at DESC').paginate(:page => params[:page])
  end
  # def index_all
    # # won't show instrument order_details
    # @order_details = session_user.order_details.
      # non_reservations.
      # where("orders.ordered_at IS NOT NULL").
      # order('orders.ordered_at DESC').
      # paginate(:page => params[:page])
  # end
end
