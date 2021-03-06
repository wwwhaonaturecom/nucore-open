require "rails_helper"
require "product_shared_examples"

RSpec.describe Item do
  it "should create using factory" do
    @facility         = FactoryBot.create(:facility)
    @facility_account = @facility.facility_accounts.create(FactoryBot.attributes_for(:facility_account))
    @item             = @facility.items.create(FactoryBot.attributes_for(:item, facility_account_id: @facility_account.id))
    expect(@item).to be_valid
    expect(@item.type).to eq("Item")
  end

  it_should_behave_like "NonReservationProduct", :item

end
