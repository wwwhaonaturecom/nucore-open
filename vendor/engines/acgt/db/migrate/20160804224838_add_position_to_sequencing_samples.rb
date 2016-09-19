class AddPositionToSequencingSamples < ActiveRecord::Migration
  def change
    add_column :sanger_sequencing_samples, :well_position, :string
  end
end
