class CreateJxmlHolidays < ActiveRecord::Migration
  def self.up
    create_table(:jxml_holidays){|t| t.date :date, :null => false }
  end

  def self.down
    drop_table :jxml_holidays
  end
end
