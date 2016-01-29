module NuCardconnect
  class MerchantAccountsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_and_authorize_merchant_account
    before_filter :set_active_tab
    admin_tab :all

    layout "two_column"

    def edit
    end

    def update
      if @merchant_account.update_attributes(params[:nu_cardconnect_merchant_account])
        flash[:notice] = t("nu_cardconnect.merchant_accounts.update_success")
        redirect_to facility_merchant_account_path
      else
        render :edit
      end
    end

    private

    def load_and_authorize_merchant_account
      @merchant_account = MerchantAccount.new(current_facility)
      authorize! :edit, @merchant_account
    end

    def facility_merchant_account_path
      NuCardconnect::Engine.routes.url_helpers.facility_merchant_account_path(current_facility.url_name)
    end
    helper_method :facility_merchant_account_path

    def set_active_tab
      @active_tab = 'admin_facility'
    end
  end
end
