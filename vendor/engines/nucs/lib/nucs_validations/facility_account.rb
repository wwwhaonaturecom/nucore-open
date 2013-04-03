module NucsValidations::FacilityAccount
  extend ActiveSupport::Concern

  included do
    validates_format_of :revenue_account, :with => /^[45]/, :message => I18n.t('activerecord.errors.facility_account.revenue_account.format')
  end
end