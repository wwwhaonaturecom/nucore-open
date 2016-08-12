require "rails_helper"

RSpec.describe SangerSequencing::Sample do
  describe "a new sample" do
    let(:sample) { FactoryGirl.build(:sanger_sequencing_sample) }

    it "is valid" do
      expect(sample).to be_valid
    end
  end

  describe "updating the sample" do
    let(:submission) { FactoryGirl.build_stubbed(:sanger_sequencing_submission) }
    subject(:sample) { FactoryGirl.build_stubbed(:sanger_sequencing_sample, submission: submission) }

    before do
      allow(submission).to receive(:product).and_return(product)
      allow(sample).to receive(:new_record?).and_return(false)
    end

    describe "generic service" do
      let(:product) { FactoryGirl.build_stubbed(:service) }

      it { is_expected.to validate_presence_of(:template_type) }
      it { is_expected.to validate_presence_of(:primer_name) }

      describe "with Plasmid type" do
        before { sample.template_type = "Plasmid" }
        it { is_expected.not_to validate_presence_of(:pcr_product_size) }
      end

      describe "with PCR type" do
        before { sample.template_type = "PCR" }
        it { is_expected.to validate_presence_of(:pcr_product_size) }
      end
    end

    describe "premium service" do
      let(:product) { FactoryGirl.build_stubbed(:service, acgt_service_type: "premium") }

      it { is_expected.not_to validate_presence_of(:template_concentration) }
      it { is_expected.not_to validate_presence_of(:primer_concentration) }
    end

    describe "standard service" do
      let(:product) { FactoryGirl.build_stubbed(:service, acgt_service_type: "standard") }

      it { is_expected.to validate_presence_of(:template_concentration) }
      it { is_expected.to validate_presence_of(:primer_concentration) }
    end

    describe "low cost" do
      let(:product) { FactoryGirl.build_stubbed(:service, acgt_service_type: "lowcost") }

      it { is_expected.not_to validate_presence_of(:template_concentration) }
      it { is_expected.not_to validate_presence_of(:primer_concentration) }
    end
  end
end
