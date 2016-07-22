module Acgt

  class OrderDetailSerializer

    attr_reader :order_detail
    delegate :order, :order_status, to: :order_detail
    delegate :name, to: :order_status, prefix: true
    delegate :ordered_at, :user, to: :order

    def initialize(order_detail)
      @order_detail = order_detail
    end

    def to_h(with_samples: false)
      if order_detail.blank?
        {}
      elsif with_samples
        as_hash.merge(samples: samples)
      else
        as_hash
      end
    end

    private

    def as_hash
      {
        order_id: order_detail.to_s,
        ordered_at: ordered_at.iso8601,
        purchased_for: UserSerializer.new(user).to_h,
        status: order_status_name,
        service_type: "premium", # TODO: may also be "standard"
        note: order_detail.note,
      }
    end

    def samples # TODO: pull values from the database; these are examples
      [
        {
          sample_id: 1123, # TODO: get from sanger_sequencing_samples.id
          template: {
            name: "sample1",
            concentration: "50", # units are ng/uL according to the form
            high_gc: false,
            hair_pin: true,
            type: "plasmid", # may be "plasmid" or "unpurified PCR"
            pcr_product_size: "20", # TODO: units not specified on the form; possibly uL?
          },
          primer: {
            name: "t7_forward",
            concentration: "200", # units are pmol/uL according to the form
          },
        },

        {
          sample_id: 1124,
          template: {
            name: "sample2",
            concentration: "20",
            high_gc: true,
            hair_pin: false,
            type: "unpurified PCR",
            pcr_product_size: "100",
          },
          primer: {
            name: "t7_reverse",
            concentration: "500",
          },
        },
      ]
    end

  end

end
