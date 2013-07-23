module NucsValidations::Product
  extend ActiveSupport::Concern

  included do
    validates_format_of :account,
                        :with => /^7/,
                        :message => Proc.new { I18n.t('activerecord.errors.product.account.format') },
                        :if => lambda { account_required && SettingsHelper.feature_on?(:expense_accounts) }
  end
end
