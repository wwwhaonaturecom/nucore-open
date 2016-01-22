require "rails_helper"

RSpec.describe Statement do
  subject(:statement) { described_class.new }

  it "sets a uuid" do
    expect { statement.save }.to change { statement.uuid }
  end

  describe "#credit_card_payable?" do
    subject(:statement) { described_class.new(facility: facility) }

    describe "the facility does not have a merchant id" do
      let(:facility) { FactoryGirl.build(:facility, card_connect_merchant_id: nil) }
      it { is_expected.not_to be_credit_card_payable }
    end

    describe "the facility does have a merchant id" do
      let(:facility) { FactoryGirl.build(:facility, card_connect_merchant_id: "12345") }

      describe "and it is a zero-dollar statement" do
        before { allow(statement).to receive(:total_cost).and_return 0 }
        it { is_expected.not_to be_credit_card_payable }
      end

      describe "and it has a non-zero dollar amount" do
        before { allow(statement).to receive(:total_cost).and_return 30 }
        it { is_expected.to be_credit_card_payable }
      end
    end
  end
end
