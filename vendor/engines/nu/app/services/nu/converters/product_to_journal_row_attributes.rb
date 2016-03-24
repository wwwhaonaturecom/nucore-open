module Nu

  module Converters

    class ProductToJournalRowAttributes

      attr_accessor :journal, :product, :total
      delegate :facility_account, to: :product

      def initialize(journal, product, total)
        @journal = journal
        @product = product
        @total = total
      end

      def convert
        {
          account: facility_account.revenue_account,
          activity: facility_account.activity,
          amount: total * -1,
          chart_field1: facility_account.chart_field1,
          dept: facility_account.dept,
          description: product.to_s,
          fund: facility_account.fund,
          program: facility_account.program,
          project: facility_account.project,
          journal_id: journal.try(:id),
        }
      end

    end

  end

end
