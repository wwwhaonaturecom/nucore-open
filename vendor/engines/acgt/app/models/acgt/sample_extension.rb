module Acgt

  module SampleExtension

    extend ActiveSupport::Concern

    included do
      validates :template_type, :primer_name, presence: true, on: :update
      validates :pcr_product_size, presence: true, if: :pcr?, on: :update
      validates :template_concentration, :primer_concentration, presence: true, if: :standard_product?, on: :update
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
