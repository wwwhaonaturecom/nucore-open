class AddBiTable < ActiveRecord::Migration

  def self.up
    create_table :bi_netids do |t|
      t.string :netid, null: false
      t.references :facility, null: false
      t.foreign_key :facilities
    end

    add_index :bi_netids, :netid
    add_index :bi_netids, :facility_id
  end

  def self.down
    remove_index :bi_netids, :netid
    remove_index :bi_netids, :facility_id
    drop_table :bi_netids
  end

end
