require "rails_helper"

RSpec.describe NuResearchSafety::Certificate do
  let(:certificate) { FactoryGirl.create(:certificate) }

  context "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:deleted_at) }
  end

  describe "#destroy" do
    it "soft deletes certificate" do
      certificate.destroy
      expect(certificate.deleted_at).to be_present
    end
  end
end
