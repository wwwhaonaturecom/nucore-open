require 'spec_helper'

describe NufsAccount do
  before(:each) do
    @facility          = Factory.create(:facility)
    @user              = Factory.create(:user)
    @nufs_account      = Factory.create(:nufs_account, :account_users_attributes => [{:user => @user, :created_by => @user, :user_role => 'Owner'}])

    @pmu_dept = stub 'pmu'
    @pmu_dept.stub(:pmu).and_return 'Best Department Ever'
    PmuDepartment.stub(:find_by_nufin_id).and_return @pmu_dept
  end

  it 'should return pmu description' do
    @nufs_account.pmu_description.should == @pmu_dept.pmu
  end

  it 'should include pmu in description' do
    @nufs_account.to_s.should include(@pmu_dept.pmu)
  end
end
