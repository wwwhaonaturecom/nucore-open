require "acgt/api_error"

module Acgt

  class OrderDetailApi

    VALID_STATUSES = %w(Submit Package\ Received Repeated Completed Cancel Canceled)

    attr_reader :order_detail_id

    def initialize(order_detail_id)
      @order_detail_id = order_detail_id
    end

    def self.find(order_detail_id)
      api = new(order_detail_id)
      raise Acgt::ApiError, "Order #{order_detail_id} not found" unless api.orders.present?
      api
    end

    def new?
      status == "submit"
    end

    def complete?
      status == "completed"
    end

    def in_process?
      !new? && !complete? && !canceled?
    end

    def canceled?
      status.in?(["cancel", "canceled"])
    end

    def status
      # TODO: Consider removing this later once everything is stabilized and we
      # know they're giving us the values they said they would.
      raise "Invalid Status from ACGT: #{order["orderstatus"]} on OrderDetail##{order_detail_id}" unless order["orderstatus"].in?(VALID_STATUSES)
      order["orderstatus"].downcase
    end

    def sample_count
      order["samplenumber"].to_i
    end

    def orders
      response.with_indifferent_access["order"]
    end

    def order
      orders.first
    end

    private

    def response
      return @response if @response
      conn = Faraday.new(url: "#{Settings.acgt.base_url}/orders/orderid/") do |faraday|
        faraday.headers["Content-Type"] = "application/json"
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth(Settings.acgt.api.username, Settings.acgt.api.password)
      end

      @response = JSON.parse(conn.get(order_detail_id).body)
    end

  end

end
