# This migration comes from nu_cardconnect_engine (originally 20151117214148)
class AddCardConnectMerchantId < ActiveRecord::Migration

  def change
    add_column :facilities, :card_connect_merchant_id, :string
    add_column :facilities, :card_connect_location_id, :string
  end

end
