class AlterProductsAddReserveInterval < ActiveRecord::Migration

  def change
    add_column :products, :reserve_interval, :integer
  end

end
