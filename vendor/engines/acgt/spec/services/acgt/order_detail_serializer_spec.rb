require "rails_helper"

RSpec.describe Acgt::OrderDetailSerializer do
  describe "#to_a" do
    subject { described_class.new(order_detail).to_h(with_samples: with_samples) }
    let(:with_samples) { false }

    context "when the order_detail exists" do
      let(:expected_hash) do
        {
          order_id: order_detail.to_s,
          ordered_at: "2015-12-01T10:30:00-06:00",
          purchased_for: { first_name: user.first_name, last_name: user.last_name, email: user.email },
          status: order_detail.order_status.name,
          service_type: "standard",
          note: order_detail.note.to_s,
        }
      end

      let(:expected_hash_with_samples) do
        expected_hash.merge(samples: expected_samples)
      end

      let(:order) { FactoryGirl.create(:purchased_order, product: service, ordered_at: ordered_at) }
      let(:order_detail) { order.order_details.first }
      let(:ordered_at) { DateTime.parse("2015-12-01T10:30:00-06:00") }
      let(:service) { FactoryGirl.create(:setup_service, acgt_service_type: "standard") }
      let(:user) { order.user }

      context "when not requesting embedded samples" do
        let(:with_samples) { false }
        it { is_expected.to match(expected_hash) }
      end

      context "when requesting embedded samples" do
        let(:submission) { FactoryGirl.create(:sanger_sequencing_submission, order_detail: order_detail) }
        let!(:sample1) do
          FactoryGirl.create(:sanger_sequencing_sample,
            submission: submission,
            customer_sample_id: "sample1",
            template_concentration: "50",
            hair_pin: true,
            template_type: "plasmid",
            pcr_product_size: "20",
            primer_name: "t7_forward",
            primer_concentration: "200",
            well_position: "A01")
        end

        let!(:sample2) do
          FactoryGirl.create(:sanger_sequencing_sample,
            submission: submission,
            customer_sample_id: "sample2",
            template_concentration: "20",
            high_gc: true,
            template_type: "pcr",
            pcr_product_size: "100",
            primer_name: "t7_reverse",
            primer_concentration: "500",
            well_position: "A02")
        end

        let(:expected_samples) do # TODO: replace these hardcoded example values
        [
          {
            sample_id: sample1.id,
            well_position: "A01",
            template: {
              name: "sample1",
              concentration: "50",
              high_gc: false,
              hair_pin: true,
              type: "plasmid",
              pcr_product_size: "20",
            },
            primer: {
              name: "t7_forward",
              concentration: "200",
            },
          },

          {
            sample_id: sample2.id,
            well_position: "A02",
            template: {
              name: "sample2",
              concentration: "20",
              high_gc: true,
              hair_pin: false,
              type: "pcr",
              pcr_product_size: "100",
            },
            primer: {
              name: "t7_reverse",
              concentration: "500",
            },
          },
        ]
      end

        let(:with_samples) { true }
        it { is_expected.to match(expected_hash_with_samples) }
      end
    end

    context "when the order_detail does not exist" do
      let(:order_detail) { nil }
      it { is_expected.to eq({}) }
    end
  end
end
