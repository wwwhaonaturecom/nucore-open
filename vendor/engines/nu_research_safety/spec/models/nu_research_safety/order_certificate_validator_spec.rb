require "rails_helper"

RSpec.describe NuResearchSafety::OrderCertificateValidator do
  let(:product_one) { FactoryGirl.create(:setup_item) }
  let(:certificate_a) { FactoryGirl.create(:product_certification_requirement, product: product_one).certificate }
  let(:user) { FactoryGirl.create(:user) }
  let(:order_by_user) { FactoryGirl.create(:order, user: user, created_by: created_by.id) }
  let(:created_by) { user }
  let!(:order_detail_one) { FactoryGirl.create(:order_detail, order: order_by_user, product: product_one) }

  let(:product_two) { FactoryGirl.create(:setup_item) }
  let(:certificate_b) { FactoryGirl.create(:product_certification_requirement, product: product_two).certificate }
  let!(:certification_req_p2_cA) { FactoryGirl.create(:product_certification_requirement, nu_safety_certificate: certificate_a, product: product_two) }
  let!(:order_detail_two) { FactoryGirl.create(:order_detail, order: order_by_user, product: product_two) }

  describe "#valid?" do
    subject(:validator) { described_class.new(order_by_user) }

    context "with one invalid product" do
      before do
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_a.name).and_return(true)
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_b.name).and_return(false)
      end

      it { is_expected.not_to be_valid }
    end

    context "with both products valid" do
      before do
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_a.name).and_return(true)
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_b.name).and_return(true)
      end

      it { is_expected.to be_valid }
    end

    context "when ordered on behalf of" do
      let(:created_by) { FactoryGirl.create(:user) }

      context "with one invalid product" do
        before do
          expect(NuResearchSafety::CertificateApi).not_to receive(:certified?)
        end

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#missing_certs_by_order_detail" do
    subject(:validator) { described_class.new(order_by_user) }

    context "with one invalid product" do
      before do
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_a.name).and_return(true)
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_b.name).and_return(false)
      end

      it "returns a hash of the order detail and its missing certificate" do
        expected_hash = { order_detail_two => [certificate_b] }
        expect(validator.missing_certs_by_order_detail).to eq expected_hash
      end
    end

    context "with both products valid" do
      before do
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_a.name).and_return(true)
        expect(NuResearchSafety::CertificateApi).to receive(:certified?).with(user.username, certificate_b.name).and_return(true)
      end

      it "returns an empty hash" do
        expected_hash = {}
        expect(validator.missing_certs_by_order_detail).to eq expected_hash
      end
    end
  end
end
