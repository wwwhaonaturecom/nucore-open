class AddChartField1ToJournalRow < ActiveRecord::Migration
  def change
    add_column :journal_rows, :chart_field1, :string, :limit => 4
  end
end
