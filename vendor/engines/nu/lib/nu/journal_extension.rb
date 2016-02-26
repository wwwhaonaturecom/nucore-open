module Nu
  module JournalExtension

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
