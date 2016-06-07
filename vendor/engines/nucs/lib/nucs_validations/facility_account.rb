module NucsValidations::FacilityAccount

  extend ActiveSupport::Concern

  included do
    validates_format_of :revenue_account,
                        with: /\A[45]/,
                        unless: :nucs_facility_account_whitelisted?,
                        message: proc { I18n.t("activerecord.errors.facility_account.revenue_account.format") }
    validates :revenue_account,
              numericality: {
                greater_than_or_equal_to: 10_000,
                less_than_or_equal_to: 99_999,
              }
  end

  private

  def nucs_facility_account_whitelisted?
    revenue_account == 78_767
  end

end
