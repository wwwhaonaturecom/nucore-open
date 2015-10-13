require "rails_helper"

RSpec.describe NuCardconnect::MerchantAccount do
  let(:merchant_id) { "123" }
  let(:location_id) { "987" }
  let(:facility) { FactoryGirl.build_stubbed(:facility, card_connect_merchant_id: merchant_id, card_connect_location_id: location_id) }
  subject(:merchant_account) { described_class.new(facility) }

  describe "validations" do
    describe "with both set" do
      it { is_expected.to be_valid }
    end

    describe "with neither value set" do
      let(:merchant_id) { nil }
      let(:location_id) { nil }

      it { is_expected.to be_valid }
    end

    describe "with only the merchant_id set" do
      let(:location_id) { nil }

      it "requires the location id" do
        expect(merchant_account).not_to be_valid
        expect(merchant_account.errors).to include(:card_connect_location_id)
      end
    end
  end

  describe "getters and setters" do
    it "has the facility's merchant id" do
      expect(merchant_account.card_connect_merchant_id).to eq("123")
    end

    it "has the facility's location id" do
      expect(merchant_account.card_connect_location_id).to eq("987")
    end

    it "sets the merchant id on the facility" do
      merchant_account.card_connect_merchant_id = "123456"
      expect(facility.card_connect_merchant_id).to eq("123456")
    end

    it "sets the location id on the facility" do
      merchant_account.card_connect_location_id = "987654"
      expect(facility.card_connect_location_id).to eq("987654")
    end
  end

  describe "assign_attributes" do
    it "assigns only the valid values to the facility" do
      merchant_account.assign_attributes(card_connect_merchant_id: "123456",
        card_connect_location_id: "987654", abbreviation: "ABCD")
      expect(facility.card_connect_merchant_id).to eq("123456")
      expect(facility.card_connect_location_id).to eq("987654")
      expect(facility.abbreviation).not_to eq("ABCD")
    end
  end

  describe "update_attributes" do
    let(:facility) { FactoryGirl.create(:facility, card_connect_merchant_id: merchant_id, card_connect_location_id: location_id) }

    describe "when valid" do
      it "saves the values to the facility" do
        merchant_account.update_attributes(card_connect_merchant_id: "345")
        expect(facility.reload.card_connect_merchant_id).to eq("345")
      end
    end

    describe "when invalid" do
      before { expect(merchant_account).to receive(:valid?).and_return false }

      it "does not save the facility" do
        merchant_account.update_attributes(card_connect_merchant_id: "345")
        expect(facility.reload.card_connect_merchant_id).not_to eq("345")
      end
    end
  end
end
