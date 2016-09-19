class AddWellPlateNumberToAcgtSamples < ActiveRecord::Migration
  def change
    add_column :sanger_sequencing_samples, :well_plate_number, :integer
  end
end
