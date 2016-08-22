require "rails_helper"

RSpec.describe Acgt::OrderDetailStatusUpdater do
  subject(:updater) { described_class.new(order_detail) }

  describe "#update" do
    let(:order_detail) { instance_double("OrderDetail", new?: true, complete?: false) }
    before { allow(Acgt::OrderDetailApi).to receive(:find).and_return(api) }

    describe "when it is submitted" do
      let(:api) { instance_double("Acgt::OrderDetailApi", in_process?: true, complete?: false) }

      it "changes the status to In Process" do
        expect(order_detail).to receive(:change_status!).with(OrderStatus.inprocess.first)
        updater.update
      end

      it "does not try to change if already in process" do
        expect(order_detail).to receive(:new?) { false }
        expect(order_detail).not_to receive(:change_status!)
        updater.update
      end
    end

    describe "when it is completed" do
      let(:api) { instance_double("Acgt::OrderDetailApi", complete?: true, in_process?: false) }

      it "changes the status to complete" do
        expect(order_detail).to receive(:change_status!).with(OrderStatus.complete_status)
        updater.update
      end

      it "does not try to change if already complete" do
        expect(order_detail).to receive(:complete?) { true }
        expect(order_detail).not_to receive(:change_status!)
        updater.update
      end
    end
  end

  describe ".update_all" do
    let(:facility) { FactoryGirl.create(:setup_facility) }
    let(:service) { FactoryGirl.create(:setup_service, facility: facility, acgt_service_type: "lowcost") }
    let(:non_acgt_service) { FactoryGirl.create(:setup_service, facility: facility) }

    let!(:non_purchased_order) { FactoryGirl.create(:setup_order, product: service).order_details.first }
    let!(:acgt_order) { FactoryGirl.create(:purchased_order, product: service).order_details.first }
    let!(:non_acgt_order) { FactoryGirl.create(:purchased_order, product: non_acgt_service).order_details.first }
    let!(:completed_acgt_order) { FactoryGirl.create(:purchased_order, product: service).order_details.first }
    before { completed_acgt_order.change_status!(OrderStatus.complete_status) }

    it "updates only the acgt order" do
      expect(described_class).to receive(:update).with(acgt_order)
      described_class.update_all
    end
  end
end
