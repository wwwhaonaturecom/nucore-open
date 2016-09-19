class AddPlateOrderToAcgtSubmission < ActiveRecord::Migration

  def change
    add_column :sanger_sequencing_submissions, :well_plate_fill_order, :string
  end

end
