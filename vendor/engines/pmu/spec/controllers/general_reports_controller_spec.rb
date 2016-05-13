require "rails_helper"

RSpec.describe Reports::GeneralReportsController do

  let(:facility) { FactoryGirl.create(:setup_facility) }
  let(:order) { FactoryGirl.create(:purchased_order, product: item, ordered_at: 1.month.ago) }
  let!(:order_detail) { order.order_details.first }
  let(:item) { FactoryGirl.create(:setup_item, facility: facility) }
  let!(:pmu_department) {PmuDepartment.create!(pmu: "PMUDEPT", nufin_id: order_detail.account.dept) }
  let(:user) { FactoryGirl.create(:user, :facility_director, facility: facility) }

  it "renders a PMU report" do
    sign_in user
    xhr :get, :index, report_by: :department, facility_id: facility.url_name,
      date_range_field: "ordered_at", date_start: 1.month.ago, status_filter: [OrderStatus.new_os.first.id]

    expect(assigns[:rows].length).to eq(1)
    expect(assigns[:rows].first.first).to eq("PMUDEPT")
  end

end
