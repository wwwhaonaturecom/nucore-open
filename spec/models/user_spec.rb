require 'spec_helper'

describe User do

  #
  # bcsec's ensuring to satisfy bcaudit on save is
  # handled in nucore by Bcaudit::Middleware which is
  # loaded at bcsec_authenticatable's initialization.
  # Since it's rack middleware, and therefore depends
  # on being a request-response cycle, it doesn't work
  # for tests. Ideally there would be a bcsec-provided
  # mock to handle this, but there isn't, so overwrite
  # the method that ensures bcaudit satisfaction so that
  # tests can proceed. Doing so allows the NU user
  # provisioning that takes place in user_extension to
  # work, making it testable
  before :all do
    Pers::Base.class_eval %Q<
      protected

      def ensure_bcauditable
      end
    >
  end

  before :each do
    @user=Factory.create(:user)
  end

  it "should validate uniquess of username" do
    # we need at least 1 user to test validations
    should validate_uniqueness_of(:username)
  end

  it "should use factory" do
    @user.should be_valid
  end

  it "should belong to NU price group if the username does not have an \"@\" symbol" do
    @user.price_groups.include?(@nupg).should == true
  end

  it "should belong to External price group if the username has an \"@\" symbol" do
    user = User.new(Factory.attributes_for(:user))
    user.username = user.email
    user.save
    user.price_groups.include?(@epg).should == true
  end

  it "should be a member of any explicitly mapped price groups" do
    facility = Factory.create(:facility)
    pg       = facility.price_groups.create(Factory.attributes_for(:price_group))
    UserPriceGroupMember.create(:user => @user, :price_group => pg)
    @user.price_groups.include?(pg).should == true
  end

  it "should belong to price groups of accounts" do
    cc       = Factory.create(:credit_card_account, :account_users_attributes => [{:user => @user, :created_by => @user, :user_role => 'Owner'}])
    facility = Factory.create(:facility)
    pg       = facility.price_groups.create(Factory.attributes_for(:price_group))
    AccountPriceGroupMember.create(:account => cc, :price_group => pg)
    @user.account_price_groups.include?(pg).should == true
  end

  it "should belong to price groups of account owner" do
    owner    = Factory.create(:user)
    cc       = Factory.create(:credit_card_account, :account_users_attributes => [{:user => owner, :created_by => owner, :user_role => 'Owner'}])
    facility = Factory.create(:facility)
    pg       = facility.price_groups.create(Factory.attributes_for(:price_group))
    UserPriceGroupMember.create(:user => owner, :price_group => pg)

    cc.account_users.create(:user => @user, :created_by => owner, :user_role => 'Purchaser')

    @user.account_price_groups.include?(pg).should == true
  end

  # Test not relevant to NU nucore -- users always externally authenticated
  #it 'should be locally authenticated' do
  #  @user.should be_authenticated_locally
  #end

  it 'should not be locally authenticated' do
    @user.encrypted_password=nil
    assert @user.save
    @user.should_not be_authenticated_locally
    @user.password_salt=nil
    assert @user.save
    @user.should_not be_authenticated_locally
  end

  it 'should alias username to login' do
    @user.should be_respond_to :login
    @user.username.should == @user.login
  end

  it 'should respond to ldap_attributes' do
    @user.should be_respond_to :ldap_attributes
  end

  it 'should not be external user' do
    @user.username.should_not == @user.email
    @user.should_not be_external
  end

  it 'should not be external user' do
    @user.username=@user.email
    @user.should be_external
  end


  it "should belong to Cancer Center price group if the user is in the Cancer Center view"

  it "cart should always return an order object with nil ordered_at"

end
