module Nu
  module Converters
    class OrderDetailToJournalRowAttributes

      attr_accessor :journal, :order_detail, :total

      def initialize(journal, order_detail, options = {})
        @journal = journal
        @order_detail = order_detail
        @total = options[:total] || order_detail.total
      end

      def convert
        [{
          account: order_detail.product.account,
          activity: order_detail.account.activity,
          amount: total,
          chart_field1: order_detail.account.chart_field1,
          dept: order_detail.account.dept,
          description: order_detail.long_description,
          fund: order_detail.account.fund,
          order_detail_id: order_detail.id,
          program: order_detail.account.program,
          project: order_detail.account.project,
          journal_id: journal.try(:id),
        }]
      end

    end
  end
end
