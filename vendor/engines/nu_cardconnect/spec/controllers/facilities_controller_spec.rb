require "rails_helper"

RSpec.describe FacilitiesController do
  let(:admin) { FactoryGirl.create(:user, :administrator) }

  before { sign_in admin }

  describe "create" do
    let(:params) { FactoryGirl.attributes_for(:facility).merge(card_connect_merchant_id: "123", card_connect_location_id: "987") }

    it "creates the facility but does not set the card connect information" do
      expect { post :create, facility: params }.to change(Facility, :count).by(1)
      facility = Facility.last
      expect(facility.card_connect_merchant_id).to be_blank
      expect(facility.card_connect_location_id).to be_blank
    end
  end

  describe "update" do
    let(:facility) { FactoryGirl.create(:facility) }

    it "does not allow updating card connect information" do
      put :update, facility_id: facility.url_name,
        facility: { card_connect_merchant_id: "123", card_connect_location_id: "987" }

      expect(facility.reload.card_connect_merchant_id).not_to eq("123")
      expect(facility.card_connect_location_id).not_to eq("987")
    end
  end
end
