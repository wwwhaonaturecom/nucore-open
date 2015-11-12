class RemoveExtraneousS3Columns < ActiveRecord::Migration
  def up
    drop_table :journal_restore if ActiveRecord::Base.connection.table_exists? :journal_restore
    remove_column :journals, :in_s3 if ActiveRecord::Base.connection.column_exists?(:journals, :in_s3)
    remove_column :stored_files, :in_s3 if ActiveRecord::Base.connection.column_exists?(:stored_files, :in_s3)
  end

  def down
  end
end
