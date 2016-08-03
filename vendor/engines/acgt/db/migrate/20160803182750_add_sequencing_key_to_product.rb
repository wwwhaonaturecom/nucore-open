class AddSequencingKeyToProduct < ActiveRecord::Migration
  def change
    add_column :products, :acgt_service_type, :string
  end
end
