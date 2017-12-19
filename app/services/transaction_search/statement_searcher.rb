module TransactionSearch

  class StatementSearcher < BaseSearcher

    def options
      Statement.where(id: order_details.pluck(:statement_id)).order_by_invoice_number
    end

    def search(params)
      order_details.where(statement_id: params)
    end

    def label_method
      :invoice_number
    end

  end

end
