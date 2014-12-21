module Nu
  module JournalExtension
    def journal_row_attributes_from_order_detail(order_detail)
      {
        account: order_detail.product.account,
        activity: order_detail.account.activity,
        amount: order_detail.total,
        chart_field1: order_detail.account.chart_field1,
        dept: order_detail.account.dept,
        description: order_detail.long_description,
        fund: order_detail.account.fund,
        journal_id: id,
        order_detail_id: order_detail.id,
        program: order_detail.account.program,
        project: order_detail.account.project,
      }
    end

    def journal_row_attributes_from_product_and_total(product, total)
      facility_account = product.facility_account
      {
        account: facility_account.revenue_account,
        activity: facility_account.activity,
        amount: total * -1,
        chart_field1: facility_account.chart_field1,
        dept: facility_account.dept,
        description: product.to_s,
        journal_id: id,
        fund: facility_account.fund,
        program: facility_account.program,
        project: facility_account.project,
      }
    end

    def create_spreadsheet
      rows = journal_rows
      return false if rows.empty?

      # write journal spreadsheet to tmp directory
      temp_file   = File.new("#{Dir::tmpdir}/journal.spreadsheet.#{Time.zone.now.strftime("%Y%m%dT%H%M%S")}.xls", "w")
      output_file = JournalSpreadsheet.write_journal_entry(rows, :output_file => temp_file.path) do |line, row|
        line[0] = row.fund
        line[1] = row.dept
        line[2] = row.project
        line[3] = row.activity
        line[4] = row.program
        line[5] = row.chart_field1
        line[6] = row.account
        line[7] = sprintf("%.2f", row.amount)
        line[8] = row.description
        line[9] =
          if row.fulfilled_at.present?
            I18n.l(row.fulfilled_at.to_date, format: :journal_line_reference)
          else
            ""
          end
      end

      # add/import journal spreadsheet
      status      = add_spreadsheet(output_file)

      # remove temp file
      File.unlink(temp_file.path) rescue nil
      status
    end

  end
end
