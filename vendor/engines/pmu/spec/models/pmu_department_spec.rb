require 'spec_helper'

describe PmuDepartment do

  it { should have_db_column(:unit_id).of_type :string }
  it { should have_db_column(:pmu).of_type :string }
  it { should have_db_column(:area).of_type :string }
  it { should have_db_column(:division).of_type :string }
  it { should have_db_column(:organization).of_type :string }
  it { should have_db_column(:fasis_id).of_type :string }
  it { should have_db_column(:fasis_description).of_type :string }
  it { should have_db_column(:nufin_id).of_type :string }
  it { should have_db_column(:nufin_description).of_type :string }

end
