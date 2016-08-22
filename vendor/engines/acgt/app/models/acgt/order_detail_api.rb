require "acgt/api_error"

module Acgt

  class OrderDetailApi

    attr_reader :order_detail_id

    def initialize(order_detail_id)
      @order_detail_id = order_detail_id
    end

    def self.find(order_detail_id)
      api = new(order_detail_id)
      raise Acgt::ApiError, "Order #{order_detail_id} not found" unless api.orders.present?
      api
    end

    def complete?
      status == "completed"
    end

    def in_process?
      status != "new" && !complete?
    end

    def orders
      response.with_indifferent_access["order"]
    end

    def order
      orders.first
    end

    private

    def status
      order["orderstatus"].downcase
    end

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
