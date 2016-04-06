module Pmu

  module Reports

    class ExportRawTransformer

      include HashHelper

      def transform(original_hash)
        insert_into_hash_after(original_hash, :account_description, pmu_department: method(:pmu_description))
      end

      private

      def pmu_description(order_detail)
        order_detail.account.respond_to?(:pmu_description) ? order_detail.account.pmu_description : nil
      end

    end

  end

end
