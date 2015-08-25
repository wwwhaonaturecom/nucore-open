
require "spec_helper"

describe "General reports controller tranlations" do
  it "includes the PMU header (i.e. the override in the engine takes precedence)" do
    expect(I18n.t("controllers.general_reports.headers.data")).to include("Account Department")
  end
end
