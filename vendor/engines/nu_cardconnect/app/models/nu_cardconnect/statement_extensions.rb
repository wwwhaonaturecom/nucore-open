module NuCardconnect
  module StatementExtensions
    extend ActiveSupport::Concern
    include Uuid

    def credit_card_payable?
      facility.supports_credit_card_payments?
    end
  end
end
