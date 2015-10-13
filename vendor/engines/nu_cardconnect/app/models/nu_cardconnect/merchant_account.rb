module NuCardconnect
  class MerchantAccount
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend ActiveModel::Naming

    attr_accessor :facility
    delegate :card_connect_merchant_id, :card_connect_merchant_id=, :card_connect_location_id,
      :card_connect_location_id=, :card_connect_merchant_id?, to: :facility

    validates :card_connect_merchant_id, numericality: { only_integer: true }, allow_blank: true
    validates :card_connect_location_id, presence: true, if: :card_connect_merchant_id?

    def initialize(facility)
      @facility = facility
    end

    def persisted?
      true
    end

    def id
      nil
    end

    def assign_attributes(attrs)
      facility.card_connect_merchant_id = attrs[:card_connect_merchant_id] if attrs[:card_connect_merchant_id]
      facility.card_connect_location_id = attrs[:card_connect_location_id] if attrs[:card_connect_location_id]
    end

    def update_attributes(attrs)
      assign_attributes(attrs)

      if valid?
        facility.save
      else
        false
      end
    end
  end
end
