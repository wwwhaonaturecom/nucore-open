require 'spec_helper'

describe User do
  describe 'price groups' do
    let(:user) { FactoryGirl.create(:user) }
    let(:cc_member) { CancerCenterMember.new(:username => user.username) }

    context 'when a user is a member of the cancer center' do
      before :each do
        CancerCenterMember.stub(:exists?).with(:username => user.username).and_return([cc_member])
      end

      it 'includes the cancer center in its price groups' do
        user.price_groups.should include PriceGroup.cancer_center.first
      end
    end

    context 'when a user is not a member of the cancer center' do
      it "doesn't include the cancer center in its price groups" do
        user.price_groups.should_not include PriceGroup.cancer_center.first
      end
    end
  end
end
