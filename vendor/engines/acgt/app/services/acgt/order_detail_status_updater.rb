require "acgt/order_detail_api"

module Acgt

  class OrderDetailStatusUpdater

    attr_reader :order_detail

    def self.update_all
      Acgt.order_details.new_or_inprocess.find_each do |od|
        begin
          update(od)
        rescue Acgt::ApiError => e
          Rails.logger.warn e.message
        end
      end
    end

    def self.update(order_detail)
      new(order_detail).update
    end

    def initialize(order_detail)
      @order_detail = order_detail
    end

    def update
      if order_detail.new? && api.in_process?
        order_detail.change_status!(OrderStatus.inprocess.first)
      elsif !order_detail.complete? && api.complete?
        order_detail.quantity = api.sample_count
        order_detail.change_status!(OrderStatus.complete_status)
      elsif api.canceled?
        order_detail.change_status!(OrderStatus.canceled_status)
      end
    end

    private

    def api
      @api ||= Acgt::OrderDetailApi.find(order_detail.to_s)
    end

  end

end
