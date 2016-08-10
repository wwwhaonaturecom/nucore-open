module Acgt

  class SampleSerializer < DelegateClass(SangerSequencing::Sample)

    def to_h
      {
        sample_id: id,
        well_position: well_position,
        template: {
          name: customer_sample_id,
          concentration: template_concentration.to_s, # units are ng/uL according to the form
          high_gc: high_gc,
          hair_pin: hair_pin,
          type: template_type.to_s, # may be "plasmid" or "unpurified PCR"
          pcr_product_size: pcr_product_size.to_s, # TODO: units not specified on the form; possibly uL?
        },
        primer: {
          name: primer_name.to_s,
          concentration: primer_concentration.to_s, # units are pmol/uL according to the form
        },
      }
    end

  end

end
