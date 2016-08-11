module Acgt

  module SubmissionsControllerExtension

    extend ActiveSupport::Concern

    included do
      skip_before_action :assert_sanger_enabled_for_facility

      permitted_submission_params.concat [:well_plate_fill_order]
      permitted_sample_attributes.concat [:template_concentration, :high_gc, :hair_pin, :template_name, :pcr_product_size,
        :template_type, :primer_name, :primer_concentration, :well_position, :well_plate_number]
    end

  end

end
