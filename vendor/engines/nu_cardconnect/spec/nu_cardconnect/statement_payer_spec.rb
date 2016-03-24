require "rails_helper"

RSpec.describe NuCardconnect::StatementPayer do
  let(:statement) { instance_double("Statement", facility: facility, paid_in_full?: false) }
  let(:facility) { instance_double("Facility", supports_credit_card_payments?: true) }
  let(:merchant_id) { 12_345_678 }
  let(:statement_amount) { BigDecimal.new("100.00") }
  subject(:payer) { described_class.new(statement, params) }

  describe "valid?" do
    let(:params) { {} }

    describe "when the facility does not support cardconnect" do
      before { allow(facility).to receive(:supports_credit_card_payments?).and_return false }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.error).to eq I18n.t("nu_cardconnect.process.no_merchant_id")
      end
    end

    describe "already paid" do
      before { allow(statement).to receive(:paid_in_full?).and_return true }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.error).to eq I18n.t("nu_cardconnect.process.already_paid")
      end
    end
  end
end
