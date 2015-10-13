module NuCardconnect
  class StatementPayer
    attr_reader :error, :params, :statement

    delegate :invoice_number, :invoice_date, :paid_in_full?, to: :statement

    def initialize(statement, params)
      @statement = statement
      @params = params
    end

    def capture
      return false unless valid?

      if authorization.capture
        Payment.create!(statement: statement, account_id: statement.account_id,
          source: :cardconnect, source_id: authorization.id,
          amount: statement_amount, processing_fee: processing_fee,
          paid_by_id: params[:current_user_id])
      else
        @error = I18n.t("nu_cardconnect.process.failure", errors: authorization.errors.join(". "))
        false
      end
    end

    def valid?
      unpaid? && valid_facility?
    end

    def statement_amount
      statement.total_cost
    end

    def processing_fee
      (statement_amount * processing_percentage).ceil(2)
    end

    def total_amount
      statement_amount + processing_fee
    end

    def processing_percentage
      percentage = BigDecimal.new(SettingsHelper.setting("cardconnect.percentage").to_s, 2)
      percentage / BigDecimal.new(100, 2)
    end

    private

    def authorization
      @authorization ||= NuCardconnect::Authorization.new(token: params[:cc_token],
        exp_month: params[:exp_month],
        exp_year: params[:exp_year],
        amount: total_amount,
        merchant_id: statement.facility.card_connect_merchant_id,
        user_fields: {
          location_id: statement.facility.card_connect_location_id,
          facility: statement.facility.to_s
        },
        order_id: statement.invoice_number)
    end

    def unpaid?
      if paid_in_full?
        @error = I18n.t("nu_cardconnect.process.already_paid")
        false
      else
        true
      end
    end

    def valid_facility?
      if statement.facility.supports_credit_card_payments?
        true
      else
        @error = I18n.t("nu_cardconnect.process.no_merchant_id")
        false
      end
    end

  end
end
