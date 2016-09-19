module Acgt

  class OrderDetailSerializer

    attr_reader :order_detail
    delegate :order, :order_status, :product, to: :order_detail
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
        service_type: service_type,
        note: order_detail.note.to_s,
      }
    end

    def samples
      submission.samples.map { |sample| SampleSerializer.new(sample).to_h }
    end

    def submission
      @submission ||= SangerSequencing::Submission.find_by(order_detail: order_detail)
    end

    def service_type
      product.acgt_service_type
    end

  end

end
