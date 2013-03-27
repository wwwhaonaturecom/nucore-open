module Pmu
  module InstrumentReportsControllerExtension

    def department
      render_report(8, 'Name') do |res|
        acct = res.order_detail.account
        acct.respond_to?(:pmu_description) ?  [ res.product.name, acct.pmu_description ] : [ res.product.name, 'Unknown' ]
      end
    end

  end
end
