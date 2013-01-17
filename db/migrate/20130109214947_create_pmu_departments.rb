#
# If using Rails >= 3.1 then you can run this migration with
# `rake pmu_engine:install:migrations`. Otherwise you'll need
# to copy it into your project's db/migrate directory and
# `rake db:migrate` from there
class CreatePmuDepartments < ActiveRecord::Migration
  def self.up
    # XML snippets from the metadata/item elements of the PMU XML
    create_table :pmu_departments do |t|
      #<item name="Primary Management Unit ID" type="xs:string" length="16"/>
      t.string :unit_id, :limit => 32
      #<item name="PMU" type="xs:string" length="182"/>
      t.string :pmu, :limit => 256
      #<item name="Area" type="xs:string" length="122"/>
      t.string :area, :limit => 128
      #<item name="Division" type="xs:string" length="122"/>
      t.string :division, :limit => 128
      #<item name="Organization" type="xs:string" length="182"/>
      t.string :organization, :limit => 256
      #<item name="FASIS Department ID" type="xs:string" length="82"/>
      t.string :fasis_id, :limit => 128
      #<item name="FASIS Department Description" type="xs:string" length="242"/>
      t.string :fasis_description, :limit => 256
      #<item name="NUFIN Department ID" type="xs:string" length="26"/>
      t.string :nufin_id, :limit => 32
      #<item name="NUFIN Department Description" type="xs:string" length="62"/>
      t.string :nufin_description, :limit => 64
      t.timestamps
    end

    add_index :pmu_departments, :nufin_id
  end

  def self.down
    remove_index :pmu_departments, :nufin_id
    drop_table :pmu_departments
  end
end
