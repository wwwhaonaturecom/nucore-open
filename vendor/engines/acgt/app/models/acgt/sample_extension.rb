module Acgt

  module SampleExtension

    extend ActiveSupport::Concern

    included do
      validates :template_type, :primer_name, presence: true, on: :update
      validates :pcr_product_size, presence: true, if: :pcr?, on: :update
      validates :template_concentration, :primer_concentration, presence: true, if: :standard_product?, on: :update
      validates :customer_sample_id, :primer_name, length: { maximum: 10 }
    end

    private

    def pcr?
      template_type == "PCR"
    end

    def standard_product?
      submission.product.acgt_service_type == "standard"
    end
  end

end
