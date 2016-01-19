# This migration comes from nu_cardconnect_engine (originally 20160119153750)
class RemoveCardConnectLocationId < ActiveRecord::Migration
  def up
    remove_column :facilities, :card_connect_location_id
  end

  def down
    add_column :facilities, :card_connect_location_id, :string
  end
end
