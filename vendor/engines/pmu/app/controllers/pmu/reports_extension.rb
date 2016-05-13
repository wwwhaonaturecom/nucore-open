module Pmu

  class ReportsExtension

    def self.general_report
      -> (order_detail) { ReportsExtension.pmu_description_for(order_detail.account) }
    end

    def self.instrument_report
      -> (reservation) { ReportsExtension.pmu_description_for(reservation.order_detail.account) }
    end

    def self.pmu_description_for(account)
      account.respond_to?(:pmu_description) ? account.pmu_description.to_s : "Unknown"
    end
  end
end
