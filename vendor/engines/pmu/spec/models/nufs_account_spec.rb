require "spec_helper"

describe NufsAccount do
  subject(:account) do
    create(:nufs_account,
      account_users_attributes: account_users_attributes_hash(user: user)
    )
  end

  let(:pmu_dept) { double "pmu" }
  let(:user) { create(:user) }

  before(:each) do
    pmu_dept.stub(:pmu).and_return "Best Department Ever"
    PmuDepartment.stub(:find_by_nufin_id).and_return pmu_dept
  end

  it_should_behave_like "an Account"

  it "returns pmu description" do
    expect(account.pmu_description).to eq pmu_dept.pmu
  end

  it "includes pmu in description" do
    expect(account.to_s).to include pmu_dept.pmu
  end
end
