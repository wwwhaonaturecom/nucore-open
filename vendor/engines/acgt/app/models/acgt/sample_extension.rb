module Acgt

  module SampleExtension

    extend ActiveSupport::Concern

    included do
      validates :template_type, :primer_name, presence: true, on: :update
      validates :pcr_product_size, presence: true, if: :pcr?, on: :update
      validates :template_concentration, :primer_concentration, presence: true, if: :standard_product?, on: :update
      validates :customer_sample_id, :primer_name, length: { maximum: 10 }
      validates :customer_sample_id, format: { with: /\A[a-zA-Z0-9.]*\z/, message: "does not allow special characters." }
      before_validation :assign_customer_sample_id
    end

    private

    def assign_customer_sample_id
      self.customer_sample_id = customer_sample_id.presence || well_position
    end

    def pcr?
      template_type == "PCR"
    end

    def standard_product?
      submission.product.acgt_service_type == "standard"
    end
  end

end
