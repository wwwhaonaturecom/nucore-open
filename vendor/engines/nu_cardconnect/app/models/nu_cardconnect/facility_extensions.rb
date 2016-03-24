module NuCardconnect

  module FacilityExtensions

    def supports_credit_card_payments?
      card_connect_merchant_id?
    end

  end

end
