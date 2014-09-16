module Pmu
  module Reports
    class ExportRaw < ::Reports::ExportRaw

      private

      def account_info_columns(account)
        super.insert(-2, pmu_description(account))
      end

      def pmu_description(account)
        account.respond_to?(:pmu_description) ? account.pmu_description : nil
      end

    end
  end
end
