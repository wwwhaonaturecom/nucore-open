require 'spec_helper'

describe Account do
  before(:each) do
    @facility          = FactoryGirl.create(:facility)
    @user              = FactoryGirl.create(:user)
    @facility_account  = @facility.facility_accounts.create(FactoryGirl.attributes_for(:facility_account))
    @item              = @facility.items.create(FactoryGirl.attributes_for(:item, :facility_account_id => @facility_account.id))
    @price_group       = FactoryGirl.create(:price_group, :facility => @facility)
    @price_group_product=FactoryGirl.create(:price_group_product, :product => @item, :price_group => @price_group)
    @price_policy      = FactoryGirl.create(:item_price_policy, :product => @item, :price_group => @price_group)
    @pg_user_member    = FactoryGirl.create(:user_price_group_member, :user => @user, :price_group => @price_group)
  end

  it "should return error if the product facility does not accept purchase orders" do
    po_account = FactoryGirl.create(:purchase_order_account, :account_users_attributes => [{:user => @user, :created_by => @user.id, :user_role => 'Owner'}])
    po_account.validate_against_product(@item, @user).should == nil
    @facility.update_attributes(:accepts_po => false)
    @item.reload #load fresh facility with update attributes
    po_account.validate_against_product(@item, @user).should_not == nil
  end

  it "should return error if the product facility does not accept credit cards" do
    cc_account=FactoryGirl.create(:credit_card_account, :account_users_attributes => [{:user => @user, :created_by => @user.id, :user_role => 'Owner'}])
    cc_account.validate_against_product(@item, @user).should == nil
    @facility.update_attributes(:accepts_cc => false)
    @item.reload #load fresh facility with update attributes
    cc_account.validate_against_product(@item, @user).should_not == nil
  end
end
