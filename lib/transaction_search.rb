module TransactionSearch

  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.searchers
    @searchers ||= {
      facilities: FacilitySearcher,
      accounts: AccountSearcher,
      products: ProductSearcher,
      account_owners: AccountOwnerSearcher,
      order_statuses: OrderStatusSearcher,
      date_range: DateRangeSearcher,
    }
  end

  class Searcher
    attr_reader :date_range_field
    def initialize(params, facility: nil, account: nil)
      @order_details = OrderDetail.purchased
      @order_details = @order_details.for_facility(facility) if facility
      @order_details = @order_details.where(account_id: account.id) if account

      @params = params
    end

    def order_details
      order_details = @order_details
                        .includes(:reservation)
                        .includes(order: :user)
                        .includes(:price_policy)
                        .preload(:bundle)

      order_details = TransactionSearch.searchers.reduce(order_details) do |ods, (key, searcher_class)|
        searcher_class.new(ods).optimized
      end

      TransactionSearch.searchers.reduce(order_details) do |ods, (key, searcher_class)|
        searcher = searcher_class.new(ods)
        results = searcher.search(@params[key])
        @date_range_field = searcher.date_range_field if key == :date_range
        results
      end
    end

    def search_options
      order_details = @order_details.reorder(nil)

      @search_options = TransactionSearch.searchers.map do |key, searcher|
        [key, searcher.new(order_details).options]
      end.to_h
    end

  end

  module ClassMethods

    # If a method is tagged with _with_search at the end, then define the normal controller
    # action to be wrapped in the search.
    # e.g. index_with_search will define #index, which will init_order_details before passing
    # control to the controller method. Then it will further filter @order_details after the controller
    # method has run
    def method_added(name)
      if name.to_s =~ /(.*)_with_search$/
        define_search_method(Regexp.last_match(1), $&)
      end
    end

    private

    def define_search_method(new_method_name, old_method_name)
      define_method(new_method_name) do
        @searcher = Searcher.new(params, facility: current_facility, account: @account)
        send(:"#{old_method_name}")
        @search_options = @searcher.search_options
        @search_fields = params
        @order_details = @searcher.order_details
        @date_range_field = @searcher.date_range_field

        @paginate_order_details = false if request.format.csv?
        sort_and_paginate
        respond_to do |format|
          format.html { render layout: @layout if @layout }
          format.csv { handle_csv_search }
        end
      end
    end

  end

  def order_by_desc
    field = @date_range_field
    if @date_range_field.to_sym == :journal_or_statement_date
      field = "COALESCE(journal_date, in_range_statements.created_at)"
    end
    @order_details.order_by_desc_nulls_first(field)
  end

  def paginate_order_details(per_page = nil)
    @per_page = per_page if per_page.present?
    @paginate_order_details = true
  end

  def order_details_sort(field)
    @order_details_sort = field
  end

  def set_default_start_date
    params[:date_range] ||= {}
    if params[:date_range][:start].blank?
      params[:date_range][:start] = format_usa_date(1.month.ago.beginning_of_month)
    end
  end

  private

  def sort_and_paginate
    @order_details = @order_details_sort ? @order_details.reorder(@order_details_sort) : order_by_desc
    @order_details = @order_details.paginate(pagination_args) if @paginate_order_details
  end

  def pagination_args
    args = { page: params[:page] }
    args[:per_page] = @per_page if @per_page.present?
    args
  end

  def handle_csv_search
    email_csv_export

    if request.xhr?
      render text: I18n.t("controllers.reports.mail_queued", email: to_email)
    else
      flash[:notice] = I18n.t("controllers.reports.mail_queued", email: to_email)
      redirect_to url_for(params.merge(format: nil, email: nil))
    end
  end

  def email_csv_export
    AccountTransactionReportMailer.delay.csv_report_email(to_email, @order_details.pluck(:id), @date_range_field)
  end

  def to_email
    params[:email] || current_user.email
  end

end
