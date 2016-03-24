require "cardconnect"

# A wrapper layer around the CardConnect Authorization class
module NuCardconnect

  class Authorization

    attr_reader :token, :amount, :merchant_id, :order_id, :capture, :user_fields

    def initialize(token:, exp_month:, exp_year:, amount:, merchant_id:, order_id: nil, user_fields: {})
      @token = token
      @exp_month = exp_month
      @exp_year = exp_year
      @amount = amount
      @merchant_id = merchant_id
      @order_id = order_id
      @capture = false
      @user_fields = user_fields
    end

    def capture
      @capture = true
      response.success?
    end

    def success?
      @response.approved?
    end

    def errors
      @response.errors
    end

    def id
      @response.retref
    end

    private

    def response
      return @response if @response
      service = CardConnect::Service::Authorization.new
      service.build_request(
        merchid: merchant_id,
        account: token,
        expiry: expiration,
        amount: amount.to_s,
        orderid: order_id.to_s,
        capture: @capture ? "Y" : "N",
        userfields: user_fields,
      )
      Rails.logger.debug "Request:"
      Rails.logger.debug service.request.payload

      @response = Response.new(service.submit)
      Rails.logger.debug "Response:"
      Rails.logger.debug @response.body
      @response
    end

    def expiration
      month = @exp_month.rjust(2, "0")
      year = @exp_year.length == 4 ? @exp_year.to_i - 2000 : @exp_year
      "#{month}#{year}"
    end

    class Response < SimpleDelegator

      def approved?
        respstat == "A"
      end

    end

  end

end
