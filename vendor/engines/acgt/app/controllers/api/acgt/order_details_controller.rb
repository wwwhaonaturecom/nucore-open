module Api

  module Acgt

    class OrderDetailsController < ApplicationController

      respond_to :json

      http_basic_authenticate_with name: Settings.acgt.nucore.username, password: Settings.acgt.nucore.password

      before_action :load_order_details, only: [:index]
      before_action :load_order_detail, only: [:show]

      def index
        render json: order_details_as_array
      end

      def show
        render json: order_detail_as_hash
      end

      private

      def order_detail_as_hash
        ::Acgt::OrderDetailSerializer.new(@order_detail).to_h(with_samples: true)
      end

      def order_details_as_array
        @order_details.map do |order_detail|
          ::Acgt::OrderDetailSerializer.new(order_detail).to_h(with_samples: false)
        end
      end

      def load_order_detail
        order_id, order_detail_id = params[:id].split(/\-/, 2)
        @order_detail = Order.purchased.find(order_id).order_details.find(order_detail_id)
      end

      def load_order_details
        @order_details =
          ::Acgt.order_details
          .joins(:order)
          .where("orders.ordered_at >= ?", date_from_param.beginning_of_day)
          .where("orders.ordered_at <= ?", date_from_param.end_of_day)
          .order(:id)
      end

      def date_from_param
        params[:date].try(:to_date) || Date.today
      end

    end

  end

end
