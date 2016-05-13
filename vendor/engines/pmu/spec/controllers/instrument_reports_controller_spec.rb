require "rails_helper"

RSpec.describe Reports::InstrumentReportsController do

  let(:facility) { FactoryGirl.create(:setup_facility) }
  let(:instrument) { FactoryGirl.create(:setup_instrument, facility: facility) }
  let!(:reservation) { FactoryGirl.create(:completed_reservation, product: instrument) }
  let(:order_detail) { reservation.order_detail }
  let!(:pmu_department) {PmuDepartment.create!(pmu: "PMUDEPT", nufin_id: order_detail.account.dept) }
  let(:user) { FactoryGirl.create(:user, :facility_director, facility: facility) }

  it "should render a PMU report" do
    sign_in user
    xhr :get, :index, report_by: :department, facility_id: facility.url_name,
      date_start: 1.month.ago, date_end: Time.current

    expect(assigns[:rows].length).to eq(1)
    expect(assigns[:rows].first.first(3)).to eq([instrument.name, "PMUDEPT", "1"])
  end

end
