require "cardconnect"
module NuCardconnect
  class PaymentsController < ApplicationController
    skip_before_filter :verify_authenticity_token, only: :postback
    before_filter :load_statement

    def pay
      if payment_action.paid_in_full?
        # If we're already paid, use a receipt instead so the amounts displayed
        # are locked to the Payment.
        @payment_action = NuCardconnect::StatementReceipt.new(@statement) if @statement.payments.any?
        render :paid_in_full
      elsif !payment_action.valid?
        flash.now[:error] = payment_action.error
        raise ActiveRecord::RecordNotFound
      else
        render :pay
      end
    end

    def process_payment
      if payment_action.capture
        flash[:alert] = t("nu_cardconnect.process.success")
        redirect_to NuCardconnect::Engine.routes.url_helpers.pay_statement_path(@statement.uuid)
      else
        flash.now[:error] = payment_action.error
        render :pay
      end
    end

    private

    def payment_action
      @payment_action ||= NuCardconnect::StatementPayer.new(@statement, payment_params)
    end

    def process_statement_path
      NuCardconnect::Engine.routes.url_helpers.process_statement_path(@statement.uuid)
    end
    helper_method :process_statement_path

    def load_statement
      @statement = Statement.find_by_uuid!(params[:uuid])
      @account = @statement.account
    end

    def payment_params
      params.fetch(:payment, {}).merge(current_user_id: current_user.try(:id))
    end
  end
end
