module NucsValidations::FacilityAccount
  extend ActiveSupport::Concern

  included do
    validates_format_of :revenue_account,
        :with => /^[45]/,
        :unless => :nucs_facility_account_whitelisted?,
        :message => Proc.new { I18n.t('activerecord.errors.facility_account.revenue_account.format') }
  end

  private

  def nucs_facility_account_whitelisted?
     self.revenue_account == 78767
  end
end
