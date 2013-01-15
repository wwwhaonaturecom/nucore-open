require 'spec_helper'

describe NufsAccount do
  before(:each) do
    @facility          = Factory.create(:facility)
    @user              = Factory.create(:user)
    @nufs_account      = Factory.create(:nufs_account, :account_users_attributes => [{:user => @user, :created_by => @user, :user_role => 'Owner'}])

    @pmu_dept = stub 'pmu'
    @pmu_dept.stubs(:pmu).returns 'Best Department Ever'
    PmuDepartment.stubs(:find_by_nufin_id).returns @pmu_dept
  end

  it 'should include pmu in description' do
    @nufs_account.to_s.should include(@pmu_dept.pmu)
  end
end
