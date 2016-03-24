module NuCardconnect

  module StatementExtensions

    extend ActiveSupport::Concern
    include Uuid

    def credit_card_payable?
      facility.supports_credit_card_payments? && total_cost > 0
    end

  end

end
