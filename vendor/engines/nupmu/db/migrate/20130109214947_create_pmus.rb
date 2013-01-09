class CreatePmus < ActiveRecord::Migration
  def self.up
    create_table :pmus do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :pmus
  end
end
