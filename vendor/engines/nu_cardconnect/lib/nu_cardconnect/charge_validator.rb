require "nu_cardconnect/inquire"
require "active_support/core_ext/hash/indifferent_access"

# Looks up a Charge in CardConnect in order to verify if the charge was approved
# and it matches the expected amount.
# Useful if using the hosted payment service to validate the postback
module NuCardconnect

  class ChargeValidator

    attr_reader :retref, :amount
    def initialize(params)
      @params = params.symbolize_keys
      @retref = params[:retref]
      @amount = params[:amount]
    end

    def canceled?
      @params[:errorCode] == "02"
    end

    def valid?
      response.amount_matches?(amount) && response.approved?
    end

    def invalid?
      !valid?
    end

    private

    def response
      @response ||= Inquire.new(retref: retref).response
    end

  end

end
