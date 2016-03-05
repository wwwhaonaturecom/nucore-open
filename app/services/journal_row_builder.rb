require "set"

# Ported from Journal model.
# We should improve upon this logic.
class JournalRowBuilder
  include NUCore::Database::ArrayHelper

  attr_reader :order_details, :journal, :journal_rows, :errors, :options,
              :recharge_enabled, :product_recharges, :journaled_facility_ids


  # This is for when you need to create a journal row without all the additional
  # validations and error checking
  def self.create_for_single_order_detail!(journal, order_detail)
    attribute_rows = new(journal, nil).order_detail_to_journal_rows(order_detail)
    attribute_rows.each { |attr| JournalRow.create!(attr) }
  end

  def initialize(journal, order_details)
    @order_details = order_details
    @journal = journal
    reset
  end

  # Reset instance variables both on initialize and build.
  def reset
    @errors = []
    @journal_rows = []
    @journaled_facility_ids = Set.new
    @product_recharges = {}
    @recharge_enabled = SettingsHelper.feature_on?(:recharge_accounts)
  end

  # Idempotent method that builds an array of new journal_rows. Also adds to
  # errors if any problems occur. Does not save anything to the database.
  # Returns self to support chaining.
  def build
    reset
    order_details.each do |order_detail|
      validate_order_detail(order_detail)
      new_journal_rows = order_detail_to_journal_rows(order_detail)
      update_product_recharges(order_detail)
      @journal_rows.concat(new_journal_rows)
    end
    add_journal_rows_from_product_recharges
    self
  end

  # Creates journal rows for the given order_details.
  # Does not gracefully handle unexpected database failures.
  # Wrapping everything in a transaction was not an option because oracle will
  # only support 1000 transactions per request.
  # Returns self to support chaining.
  def create
    build
    if valid? && journal_rows.present?
      journal_rows.each { |journal_row| JournalRow.create!(journal_row) }
      set_journal_for_order_details(journal, order_details.map(&:id))
    end
    self
  end

  # Returns true if errors are not present; otherwise false.
  # Best to use this incase errors implementation changes.
  def valid?
    errors.blank?
  end

  # Set an array of facility_ids with pending journals
  def pending_facility_ids
    @pending_facility_ids ||= Journal.facility_ids_with_pending_journals
  end

  # Run all validations on an order detail
  def validate_order_detail(order_detail)
    validate_order_detail_unjournaled(order_detail)
    validate_facility_can_journal(order_detail)
    validate_account(order_detail)
  end

  # Validate the order_detail hasn't already been journaled
  def validate_order_detail_unjournaled(order_detail)
    if order_detail.journal_id.present?
      @errors << "#{order_detail} is already journaled in journal #{order_detail.journal_id}"
    end
  end

  # Validate the order_details's facility doesn't currently have a pending
  # journal.
  #
  # Ported from original journal model logic. Consider replacing the raised
  # error with a push to `@errors` instead.
  def validate_facility_can_journal(order_detail)
    facility_id = order_detail.order.facility_id
    unless journaled_facility_ids.member?(facility_id)
      if pending_facility_ids.member?(facility_id)
        raise ::Journal::CreationError.new(I18n.t(
          "activerecord.errors.models.journal.pending_overlap",
          label: order_detail.to_s,
          facility: Facility.find(facility_id)
        ))
      else
        journaled_facility_ids.add(facility_id)
      end
    end
  end

  # Validate each journal_row account. This is necessary because an order_detail
  # may generate multiple journal_rows with different accounts, and we need to
  # validate them all.
  #
  # TODO: we may need to add a validator factory for split_accounts. Otherwise
  # we assume a product account can not be a split account.
  def validate_account(order_detail)
    account = order_detail.account
    begin
      ValidatorFactory.instance(account.account_number, order_detail.product.account).account_is_open!(order_detail.fulfilled_at)
    rescue ValidatorError => e
      @errors << I18n.t(
        "activerecord.errors.models.journal.invalid_account",
        account_number: account.account_number_to_s,
        validation_error: e.message
      )
    end
  end

  # Given an order detail, return an array of one or more new JournalRow
  # objects.
  def order_detail_to_journal_rows(order_detail)
    factory = Converters::ConverterFactory.new(account: order_detail.account)
    klass = factory.for("order_detail_to_journal_rows")
    klass.new(journal, order_detail).convert
  end

  # Given a product and total, return an array of one or more new JournalRow
  # objects.
  def product_to_journal_rows(product, total)
    factory = Converters::ConverterFactory.new
    klass = factory.for("product_to_journal_rows")
    klass.new(journal, product, total).convert
  end

  # If recharge_enabled, then sum up the product_recharges by product so each
  # product recharge can later be added as an additional journal_row.
  def update_product_recharges(order_detail)
    if recharge_enabled
      product_id = order_detail.product_id
      product_recharges[product_id] ||= 0
      product_recharges[product_id] += order_detail.total
    end
  end

  # When you’re creating a journal, for a single order detail you’ll have one
  # or more journal rows for money coming out of an account and one journal row
  # for the money going into the recharge account. One journal row is positive
  # and one is negative. Only builds journal_rows if the recharge_enabled
  # feature is enabled.
  def add_journal_rows_from_product_recharges
    product_recharges.each_pair do |product_id, total|
      product = Product.find(product_id)
      new_journal_rows = product_to_journal_rows(product, total)
      @journal_rows.concat(new_journal_rows)
    end
  end

  # Updates the journal_id of each order_detail.
  def set_journal_for_order_details(journal, order_detail_ids)
    array_slice(order_detail_ids) do |id_slice|
      OrderDetail.where(id: id_slice).update_all(journal_id: journal.id)
    end
  end

end