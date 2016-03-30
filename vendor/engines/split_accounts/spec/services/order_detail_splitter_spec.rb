require "rails_helper"

RSpec.describe SplitAccounts::OrderDetailSplitter, type: :service do
  describe "item/service orders" do
    let(:subaccount_1) { build_stubbed(:nufs_account) }
    let(:subaccount_2) { build_stubbed(:nufs_account) }

    let(:split_account) do
      build_stubbed(:split_account).tap do |split_account|
        split_account.splits.build percent: 50, apply_remainder: true, subaccount: subaccount_1
        split_account.splits.build percent: 50, apply_remainder: false, subaccount: subaccount_2
      end
    end

    let(:order) { build_stubbed(:order) }

    let(:order_detail) do
      build_stubbed(:order_detail, created_by: 1,
                                   quantity: 3,
                                   actual_cost: BigDecimal("9.99"),
                                   actual_subsidy: BigDecimal("19.99"),
                                   estimated_cost: BigDecimal("29.99"),
                                   estimated_subsidy: BigDecimal("39.99"),
                                   account: split_account)
    end

    it "can be initialized" do
      expect(described_class.new(order_detail))
    end

    describe "#split" do
      let(:results) { described_class.new(order_detail).split }

      it "returns correct number of split order details" do
        expect(results.size).to eq(split_account.splits.size)
      end

      it "dups original order detail" do
        results.each do |result|
          expect(result.created_by).to eq(order_detail.created_by)
        end
      end

      it "maintains the ID display" do
        results.each do |result|
          expect(result.to_s).to eq(order_detail.to_s)
        end
      end

      it "changes account" do
        expect(results.map(&:account)).to contain_exactly(subaccount_1, subaccount_2)
      end

      it "splits quantity" do
        expect(results.map(&:quantity)).to contain_exactly(1.5, 1.5)
      end

      it "splits actual_cost" do
        expect(results.map(&:actual_cost)).to contain_exactly(5.0, 4.99)
      end

      it "splits actual_subsidy" do
        expect(results.map(&:actual_subsidy)).to contain_exactly(10.0, 9.99)
      end

      it "splits estimated_cost" do
        expect(results.map(&:estimated_cost)).to contain_exactly(15.0, 14.99)
      end

      it "splits estimated_subsidy" do
        expect(results.map(&:estimated_subsidy)).to contain_exactly(20.0, 19.99)
      end
    end
  end

  describe "order_details with reservations" do
    let(:subaccount_1) { build_stubbed(:nufs_account) }
    let(:subaccount_2) { build_stubbed(:nufs_account) }
    let(:subaccount_3) { build_stubbed(:nufs_account) }

    let(:split_account) do
      build_stubbed(:split_account).tap do |split_account|
        split_account.splits.build percent: 33.34, apply_remainder: true, subaccount: subaccount_1
        split_account.splits.build percent: 33.33, apply_remainder: false, subaccount: subaccount_2
        split_account.splits.build percent: 33.33, apply_remainder: false, subaccount: subaccount_3
      end
    end

    let(:order_detail) do
      build_stubbed(:order_detail, reservation: reservation,
                                   created_by: 1,
                                   quantity: 1,
                                   actual_cost: BigDecimal("9.99"),
                                   actual_subsidy: BigDecimal("19.99"),
                                   estimated_cost: BigDecimal("29.99"),
                                   estimated_subsidy: BigDecimal("39.99"),
                                   account: split_account)
    end

    let(:start_at) { 1.hour.ago }
    let(:reservation) do
      build_stubbed(:reservation, reserve_start_at: start_at,
                                  reserve_end_at: start_at + 30.minutes, actual_start_at: start_at,
                                  actual_end_at: start_at + 45.minutes)
    end
    let(:results) { described_class.new(order_detail, split_reservations: true).split.map(&:reservation) }

    it "splits the reservation minutes" do
      expect(results.map(&:duration_mins)).to eq([10.02, 9.99, 9.99])
    end

    it "splits the actual minutes" do
      expect(results.map(&:actual_duration_mins)).to eq([15.02, 14.99, 14.99])
    end

    it "splits the order detail's accounts" do
      expect(results.map { |res| res.order_detail.account }).to eq([subaccount_1, subaccount_2, subaccount_3])
    end

    it "splits to order details costs" do
      expect(results.map { |res| res.order_detail.actual_cost }).to eq([3.35, 3.32, 3.32])
    end

    it "copies the reservation start and end times" do
      expect(results.map(&:reserve_start_at)).to all(eq(start_at))
      expect(results.map(&:reserve_end_at)).to all(eq(start_at + 30.minutes))
    end

    it "copies the actual start and end times" do
      expect(results.map(&:actual_start_at)).to all(eq(start_at))
      expect(results.map(&:actual_end_at)).to all(eq(start_at + 45.minutes))
    end
  end
end
