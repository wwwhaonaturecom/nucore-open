require "acgt/engine" if defined?(Rails)

module Acgt

  def self.order_details
    # doing the pluck is significantly faster than letting oracle use a subquery
    product_ids = ::Product.where.not(acgt_service_type: nil).pluck(:id)
    ::OrderDetail.where(product_id: product_ids)
  end

end
