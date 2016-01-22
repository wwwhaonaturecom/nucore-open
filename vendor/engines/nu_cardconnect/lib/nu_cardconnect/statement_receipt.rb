module NuCardconnect
  class StatementReceipt
    attr_reader :statement

    delegate :invoice_number, :invoice_date, :paid_in_full?, to: :statement

    def initialize(statement)
      @statement = statement
    end

    def statement_amount
      payment.amount
    end

    def processing_fee
      payment.processing_fee
    end

    def total_amount
      statement_amount + processing_fee
    end

    def paid_at
      payment.try(:created_at)
    end

    private

    def payment
      @payment ||= statement.payments.first
    end
  end
end
