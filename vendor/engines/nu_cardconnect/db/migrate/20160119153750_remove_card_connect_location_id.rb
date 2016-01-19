class RemoveCardConnectLocationId < ActiveRecord::Migration
  def up
    remove_column :facilities, :card_connect_location_id
  end

  def down
    add_column :facilities, :card_connect_location_id, :string
  end
end
