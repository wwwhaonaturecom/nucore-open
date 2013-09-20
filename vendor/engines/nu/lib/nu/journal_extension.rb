module Nu
  module JournalExtension

    def create_journal_rows!(order_details)
      recharge_by_product = {}
      facility_ids_already_in_journal = Set.new
      order_detail_ids = []
      pending_facility_ids = Journal.facility_ids_with_pending_journals
      row_errors = []

      # create rows for each transaction
      order_details.each do |od|
        od_facility_id = od.order.facility_id
        row_errors << "##{od} is already journaled in journal ##{od.journal_id}" if od.journal_id
        account = od.account

        # unless we've already encountered this facility_id during
        # this call to create_journal_rows,
        unless facility_ids_already_in_journal.member? od_facility_id

          # check against facility_ids which actually have pending journals
          # in the DB
          if pending_facility_ids.member? od_facility_id
            raise "#{od.to_s}: Facility #{Facility.find(od_facility_id)} already has a pending journal"
          end
          facility_ids_already_in_journal.add(od_facility_id)
        end

        begin
          ValidatorFactory.instance(account.account_number, od.product.account).account_is_open!(od.fulfilled_at)
        rescue ValidatorError => e
          row_errors << "Account #{account} on order detail ##{od} is invalid. It #{e.message}."
        end

        JournalRow.create!(
          :journal_id      => id,
          :order_detail_id => od.id,
          :amount          => od.total,
          :description     => "##{od}: #{od.order.user}: #{od.fulfilled_at.strftime("%m/%d/%Y")}: #{od.product} x#{od.quantity}",
          :fund            => account.fund,
          :dept            => account.dept,
          :project         => account.project,
          :activity        => account.activity,
          :program         => account.program,
          :chart_field1    => account.chart_field1,
          :account         => od.product.account
        )
        order_detail_ids << od.id
        recharge_by_product[od.product_id] = recharge_by_product[od.product_id].to_f + od.total
      end

      # create rows for each recharge chart string
      recharge_by_product.each_pair do |product_id, total|
        product = Product.find(product_id)
        fa      = product.facility_account
        JournalRow.create!(
          :journal_id      => id,
          :fund            => fa.fund,
          :dept            => fa.dept,
          :project         => fa.project,
          :activity        => fa.activity,
          :program         => fa.program,
          :chart_field1    => fa.chart_field1,
          :account         => fa.revenue_account,
          :amount          => total * -1,
          :description     => product.to_s
        )
      end

      OrderDetail.update_all(['journal_id = ?', self.id], ['id IN (?)', order_detail_ids]) unless row_errors.present?

      return row_errors
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
        line[9] = row.reference
      end

      # add/import journal spreadsheet
      status      = add_spreadsheet(output_file)

      # remove temp file
      File.unlink(temp_file.path) rescue nil
      status
    end

  end
end
