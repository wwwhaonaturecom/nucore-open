module NucsValidations::Product
  extend ActiveSupport::Concern

  included do
    validates_format_of :account,
                        :with => /^7/,
                        :message => lambda { I18n.t('activerecord.errors.product.account.format') },
                        :if => lambda { SettingsHelper.feature_on? :expense_accounts }
  end
end
