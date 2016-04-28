require "rails_helper"

RSpec.describe FacilityAccount do
  describe "#account_number" do
    subject(:account) { FactoryGirl.build(:facility_account, account_number: account_number) }

    def initialize_account
      define_open_account(account.revenue_account, account_number)
      account.save!
    end

    context "when the number is in a valid format" do
      before(:each) do
        expect { initialize_account }.not_to raise_error
        is_expected.to be_valid
      end

      shared_examples_for "it has a reader for" do |attribute, value|
        it "has #{attribute} of #{value}" do
          expect(account.public_send(attribute)).to eq(value)
          expect(account.reload.public_send(attribute)).to eq(value)
        end
      end

      context "fund3-dept7" do
        let(:account_number) { "123-1234567" }

        it_behaves_like "it has a reader for", :fund, "123"
        it_behaves_like "it has a reader for", :dept, "1234567"
      end

      context "fund3-dept7-project8" do
        let(:account_number) { "123-1234567-12345678" }

        it_behaves_like "it has a reader for", :fund, "123"
        it_behaves_like "it has a reader for", :dept, "1234567"
        it_behaves_like "it has a reader for", :project, "12345678"
      end

      context "fund3-dept7-project8-activity2" do
        let(:account_number) { "123-1234567-12345678-12" }

        it_behaves_like "it has a reader for", :fund, "123"
        it_behaves_like "it has a reader for", :dept, "1234567"
        it_behaves_like "it has a reader for", :project, "12345678"
        it_behaves_like "it has a reader for", :activity, "12"
      end

      context "fund3-dept7-project8-activity2-program4" do
        let(:account_number) { "123-1234567-12345678-12-1234" }

        it_behaves_like "it has a reader for", :fund, "123"
        it_behaves_like "it has a reader for", :dept, "1234567"
        it_behaves_like "it has a reader for", :project, "12345678"
        it_behaves_like "it has a reader for", :activity, "12"
        it_behaves_like "it has a reader for", :program, "1234"
      end
    end

    shared_examples_for "an invalid account number" do
      it "is invalid" do
        expect { initialize_account }.to raise_error(AccountNumberFormatError)
        is_expected.not_to be_valid
        expect(account.errors).to be_present
      end
    end

    context "fund3" do
      let(:account_number) { "123" }

      it_behaves_like "an invalid account number"
    end

    context "fund3-dept7-project8-activity2-program4-account5" do
      let(:account_number) { "123-1234567-12345678-12-1234-12345" }

      it_behaves_like "an invalid account number"
    end
  end

  describe "#revenue_account" do
    it "is a 5-digit number" do
      is_expected
        .to validate_numericality_of(:revenue_account)
        .is_greater_than_or_equal_to(10_000)
        .is_less_than_or_equal_to(99_999)
        .only_integer
    end

    it "allows numbers starting with 4" do
      expect(subject).to allow_value("41234").for(:revenue_account)
    end

    it "allows numbers starting with 5" do
      expect(subject).to allow_value("51234").for(:revenue_account)
    end

    it "disallows numbers starting with 7" do
      expect(subject).not_to allow_value("71234").for(:revenue_account)
    end

    it "disallows numbers starting with 4, but are too short" do
      expect(subject).not_to allow_value("41").for(:revenue_account)
    end

    it "disallows numbers starting with 4, but are too long" do
      expect(subject).not_to allow_value("412345").for(:revenue_account)
    end

    it "allows 78767 as an exception" do
      expect(subject).to allow_value("78767").for(:revenue_account)
    end
  end
end
