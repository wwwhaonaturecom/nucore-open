module NucsValidations::Product

  extend ActiveSupport::Concern

  included do
    validates_format_of :account,
                        with: /\A7/,
                        message: proc { I18n.t("activerecord.errors.product.account.format") },
                        if: -> { requires_account? && SettingsHelper.feature_on?(:expense_accounts) }
  end

end
