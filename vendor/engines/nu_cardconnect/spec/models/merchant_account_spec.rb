require "rails_helper"

RSpec.describe NuCardconnect::MerchantAccount do
  let(:merchant_id) { "123" }
  let(:facility) { FactoryGirl.build_stubbed(:facility, card_connect_merchant_id: merchant_id) }
  subject(:merchant_account) { described_class.new(facility) }

  describe "validations" do
    describe "with merchant id set" do
      it { is_expected.to be_valid }
    end

    describe "with merchant id blank" do
      let(:merchant_id) { nil }

      it { is_expected.to be_valid }
    end
  end

  describe "getters and setters" do
    it "has the facility's merchant id" do
      expect(merchant_account.card_connect_merchant_id).to eq("123")
    end

    it "sets the merchant id on the facility" do
      merchant_account.card_connect_merchant_id = "123456"
      expect(facility.card_connect_merchant_id).to eq("123456")
    end
  end

  describe "assign_attributes" do
    it "assigns only the valid values to the facility" do
      merchant_account.assign_attributes(card_connect_merchant_id: "123456",
        abbreviation: "ABCD")
      expect(facility.card_connect_merchant_id).to eq("123456")
      expect(facility.abbreviation).not_to eq("ABCD")
    end
  end

  describe "update_attributes" do
    let(:facility) { FactoryGirl.create(:facility, card_connect_merchant_id: merchant_id) }

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
