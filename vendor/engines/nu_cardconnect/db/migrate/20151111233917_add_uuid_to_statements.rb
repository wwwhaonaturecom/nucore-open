class AddUuidToStatements < ActiveRecord::Migration

  def up
    add_column :statements, :uuid, :string
    Statement.find_each do |statement|
      statement.update_attribute(:uuid, SecureRandom.uuid)
    end
    change_column :statements, :uuid, :string, null: false
    add_index :statements, :uuid, unique: true
  end

  def down
    remove_column :statements, :uuid
  end

end
