module TransactionSearch

  class BaseSearcher

    attr_reader :order_details

    def initialize(order_details)
      @order_details = order_details
    end

    def self.key
      to_s.demodulize.sub(/Searcher\z/, '').pluralize.underscore
    end

    def key
      self.class.key
    end

    def options
      raise NotImplementedError
    end

    def search(_params)
      raise NotImplementedError
    end

    # Include any optimizations to `order_details` such as `includes` or `preload`
    def optimized
      order_details
    end

    def label_method
      nil
    end

    def label
      nil
    end

  end

end
