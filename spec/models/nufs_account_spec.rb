require "rails_helper"

RSpec.describe NufsAccount do
  context "account number validations" do
    before(:each) do
      @user     = FactoryBot.create(:user)
      @options  = FactoryBot.attributes_for(:nufs_account, description: "account description", expires_at: Time.zone.now + 1.day, created_by: @user,
                                                           account_users_attributes: account_users_attributes_hash(user: @user))
      @starts_at  = Time.zone.now - 3.days
      @expires_at = Time.zone.now + 3.days
    end

    it "should copy account_number to display_account_number" do
      @bcs = BudgetedChartString.create(fund: "123", dept: "1234567", starts_at: @starts_at, expires_at: @expires_at)
      @options[:account_number] = "123-1234567"
      @account = NufsAccount.create(@options)
      assert_equal "123-1234567", @account.account_number
    end

    it "should not have a facility" do
      facility = FactoryBot.create(:facility)
      account = NufsAccount.create(@options)
      expect(account.facility).to be_nil
    end

    it "should not be limited to a single facility" do
      expect(NufsAccount.single_facility?).to be false
    end

  end
end
