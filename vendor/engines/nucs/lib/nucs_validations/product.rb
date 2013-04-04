module NucsValidations::Product
  extend ActiveSupport::Concern

  included do
    validates_format_of :account, :with => /^7/, :message => I18n.t('activerecord.errors.product.account.format')
  end
end
