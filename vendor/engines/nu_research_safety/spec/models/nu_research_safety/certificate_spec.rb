require "rails_helper"

RSpec.describe NuResearchSafety::Certificate do
  let(:product_certification_requirement) { FactoryGirl.create(:product_certification_requirement) }
  let(:certificate) { product_certification_requirement.certificate }

  context "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:deleted_at) }
  end

  describe "#destroy" do
    it "soft deletes certificate" do
      certificate.destroy
      expect(certificate.deleted_at).to be_present
    end
    it "soft deletes associated product_certification_requirements" do
      certificate.destroy
      expect(product_certification_requirement.reload.deleted_at).to be_present
    end
  end
end
