require "cardconnect"

# Wrapper around the CardConnect gem's Inquire service
module NuCardconnect
  class Inquire
    attr_reader :retref

    def initialize(retref:)
      @retref = retref
    end

    def response
      return @response if @response
      service = CardConnect::Service::Inquire.new
      service.build_request(retref: retref.to_s)
      @response = InquireResponse.new(service.submit)
    end

    class InquireResponse < SimpleDelegator
      def approved?
        respstat == "A"
      end

      def merchant_id
        merchid
      end

      def amount_matches?(other_amount)
        self.amount == other_amount.to_s
      end
    end
  end
end
