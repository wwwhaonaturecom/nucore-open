require "spec_helper"
require "nu_cardconnect/charge_validator"
require "ostruct"

RSpec.describe NuCardconnect::ChargeValidator do
  subject(:validator) { described_class.new({ retref: retref, amount: amount }) }
  let(:response) { OpenStruct.new(amount: "43.06", respstat: respstat) }
  before { allow_any_instance_of(CardConnect::Service::Inquire).to receive(:submit).and_return response }

  describe "valid?" do
    let(:respstat) { "A" }

    describe "a valid retref" do
      let(:retref) { "287047148207" }

      describe "and a valid amount" do
        describe "as a string" do
          let(:amount) { "43.06" }
          it { is_expected.to be_valid }
        end

        describe "as a float" do
          let(:amount) { 43.06 }
          it { is_expected.to be_valid }
        end
      end

      describe "and an invalid amount" do
        let(:amount) { "36.27" }
        it { is_expected.to be_invalid }
      end
    end
  end

  describe "invalid?" do
    let(:respstat) { "C" }
    describe "an invalid retref" do
      let(:retref) { "123456789" }
      let(:amount) { "43.06" }
      it { is_expected.to be_invalid }
    end
  end
end
