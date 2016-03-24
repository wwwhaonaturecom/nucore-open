class AddNuOracleIndexes < ActiveRecord::Migration

  def change
    add_index :accounts, :facility_id
    add_index :orders, :merge_with_order_id
    add_index :orders, :account_id
    add_index :product_users, :product_id
    add_index :instrument_statuses, :instrument_id
    add_index :products, :facility_id
    add_index :products, :facility_account_id
    add_index :account_users, :account_id
    add_index :facility_accounts, :facility_id
    add_index :price_policies, :price_group_id
    add_index :order_details, :product_accessory_id
    add_index :order_details, :parent_order_detail_id
    add_index :order_details, :product_id
    add_index :order_details, :price_policy_id
    add_index :order_details, :order_id
    add_index :order_details, :account_id
    add_index :order_details, :bundle_product_id
    add_index :reservations, :order_detail_id
    add_index :reservations, :product_id
    add_index :price_group_members, :price_group_id
    add_index :price_group_members, :account_id
    add_index :statements, :facility_id
    add_index :stored_files, :product_id
    add_index :stored_files, :created_by
    add_index :stored_files, :order_detail_id
  end

end
