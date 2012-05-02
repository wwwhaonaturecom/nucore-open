module JournalExtension

  def create_journal_rows!(order_details)
    recharge_by_product = {}

    # create rows for each transaction
    order_details.each do |od|
      raise Exception if od.journal_id
      account = od.account

      begin
        ValidatorFactory.instance(account.account_number, od.product.account).account_is_open!
      rescue ValidatorError => e
        raise "Account #{account} on order detail ##{od} is invalid. It #{e.message}."
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
        :account         => od.product.account
      )
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
        :account         => fa.revenue_account,
        :amount          => total * -1,
        :description     => product.to_s
      )
    end
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
      line[5] = row.account
      line[6] = sprintf("%.2f", row.amount)
      line[7] = row.description
      line[8] = row.reference
    end

    # add/import journal spreadsheet
    status      = add_spreadsheet(output_file)

    # remove temp file
    File.unlink(temp_file.path) rescue nil
    status
  end

end