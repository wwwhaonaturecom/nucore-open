class AddAcgtFieldsToSanger < ActiveRecord::Migration

  def change

    change_table :sanger_sequencing_samples do |t|
      t.integer :template_concentration
      t.boolean :high_gc, default: false, null: false
      t.boolean :hair_pin, default: false, null: false
      t.string :template_type
      t.integer :pcr_product_size
      t.string :primer_name
      t.integer :primer_concentration
    end

  end

end
