module NuResearchSafety

  class OrderCertificateValidator

    attr_reader :order

    delegate :ordered_on_behalf_of?, to: :order

    def initialize(order)
      @order = order
    end

    def valid?
      ordered_on_behalf_of? || has_all_certificates?
    end

    def missing_certs_by_order_detail
      order.order_details.map do |od|
        [od, missing_certificates_for(od.product)]
      end.to_h.select { |_k, v| v.any? }
    end

    def error_message
      "Missing certificates: " + missing_certs_by_order_detail.values.flatten.uniq.map(&:name).join(", ")
    end

    private

    def has_all_certificates?
      !missing_certificates?
    end

    def missing_certificates?
      missing_certs_by_order_detail.values.any?(&:present?)
    end

    def missing_certificates_for(product)
      product.certificates.reject do |cert|
        certificate_cache[cert.name]
      end
    end

    def certificate_cache
      @certificate_cache ||= Hash.new do |hash, key|
        hash[key] = NuResearchSafety::CertificateApi.certified?(order.user.username, key)
      end
    end

  end

end
