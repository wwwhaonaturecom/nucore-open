module NuResearchSafety

  class UserCertificatesController < ApplicationController

    admin_tab     :all
    before_action :authenticate_user!
    before_action :check_acting_as
    before_action :init_current_facility

    layout "two_column"

    def initialize
      @active_tab = "admin_users"
      super
    end

    def index
      @user = User.find(params[:user_id])
      @available_certificates = NuResearchSafety::Certificate.order(:name)
    end

    def check_certificate
      @user = User.find(params[:user_id])
      @certificate = Certificate.find_by(id: params[:certificate_id])

      if @certificate
        if NuResearchSafety::CertificateApi.certified?(@user.username, @certificate.name)
          flash[:notice] = text('check_certificate.success', user_name: @user.full_name, certificate_name: @certificate.name)
        else
          flash[:error] = text('check_certificate.error', user_name: @user.full_name, certificate_name: @certificate.name)
        end
      else
        flash[:error] = text('check_certificate.none')
      end

      redirect_to action: :index
    end

    # During rendering, we want to use the Ability as if we were using the UsersController
    def current_ability
      ::Ability.new(current_user, current_facility, UsersController.new)
    end

  end

end
