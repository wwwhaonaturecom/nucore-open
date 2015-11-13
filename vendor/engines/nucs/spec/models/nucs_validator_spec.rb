require "rails_helper"
require_relative "../support/nucs_validator_helper"

include NucsValidatorHelper

RSpec.describe NucsValidator do
  let(:non_grant_chart_string) { "171-5401900-10006385-01-1059-1095" }
  let(:grant_chart_string) { "191-5401900-60006385-01-1059-1095" }
  let(:zero_fund_chart_string) { "023-5401900-10006385-01-1059-1095" }
  let(:non_revenue_account) { "75340" }
  let(:revenue_account) { "50617" }

  describe "account setting" do
    it "requires a valid account" do
      expect { NucsValidator.new(non_grant_chart_string, "kfjdksjdfks") }
        .to raise_error(NucsErrors::InputError)
    end

    it "requires a valid account on account=" do
      validator = NucsValidator.new(non_grant_chart_string, revenue_account)
      expect { validator.account = "kfjdksjdfks" }.to raise_error(NucsErrors::InputError)
    end
  end

  describe "chart string setting" do
    it "requires a valid chart string" do
      expect { NucsValidator.new("kfjdksjdfks", revenue_account) }
        .to raise_error(NucsErrors::InputError)
    end

    it "requires a valid chart string on chart_string= " do
      validator = NucsValidator.new(non_grant_chart_string, revenue_account)
      expect { validator.chart_string = "kfjdksjdfks" }.to raise_error(NucsErrors::InputError)
    end
  end

  describe "format/parsing" do
    let(:validator) { NucsValidator.new(chart_string) }
    subject(:components) { validator.components.select { |_k, v| v.present? } }

    describe "just a fund and department" do
      let(:chart_string) { "123-1234567" }
      it { is_expected.to eq(fund: "123", dept: "1234567") }
    end

    describe "with a fund, department, and project" do
      let(:chart_string) { "123-1234567-12345678" }
      it { is_expected.to eq(fund: "123", dept: "1234567", project: "12345678") }
    end

    describe "invalid project" do
      describe "with a four digit project" do
        let(:chart_string) { "123-1234567-1234" }
        specify { expect { validator }.to raise_error(AccountNumberFormatError) }
      end

      describe "with a two digit project" do
        let(:chart_string) { "123-1234567-12" }
        specify { expect { validator } .to raise_error(AccountNumberFormatError) }
      end
    end

    describe "with everything up through activity" do
      let(:chart_string) { "123-1234567-12345678-12" }
      it { is_expected.to eq(fund: "123", dept: "1234567", project: "12345678", activity: "12") }
    end

    describe "with everything up through a program" do
      let(:chart_string) { "123-1234567-12345678-12-1234" }
      it { is_expected.to eq(fund: "123", dept: "1234567", project: "12345678", activity: "12", program: "1234") }
    end

    describe "with everything including chart_field1" do
      let(:chart_string) { "123-1234567-12345678-12-1234-4321" }
      it { is_expected.to eq(fund: "123", dept: "1234567", project: "12345678", activity: "12", program: "1234", chart_field1: "4321") }
    end

    describe "chartfield1 with just fund and department" do
      let(:chart_string) { "123-1234567----1025" }
      it { is_expected.to eq(fund: "123", dept: "1234567", chart_field1: "1025") }
    end

    describe "everything except program" do
      let(:chart_string) { "123-1234567-12345678-12--1234" }
      it { is_expected.to eq(fund: "123", dept: "1234567", project: "12345678", activity: "12", chart_field1: "1234") }
    end

    # this might be incorrect, but asserting for now
    describe "skipping activity" do
      let(:chart_string) { "123-1234567-12345678--1234" }
      it { is_expected.to eq(fund: "123", dept: "1234567", project: "12345678", program: "1234") }
    end
  end

  # tests below are commented out because they test logic overridden by blacklist requirements

  #  it 'validates a zero fund chart string' do
  #    define_ge001(zero_fund_chart_string)
  #    assert_nothing_raised do
  #      NucsValidator.new(zero_fund_chart_string, non_revenue_account).account_is_open!
  #    end
  #  end

  #  it 'recognizes an invalid zero fund chart string' do
  #    assert_raise NucsErrors::InputError do
  #      NucsValidator.new(zero_fund_chart_string.gsub('023-', '034-'), non_revenue_account).account_is_open!
  #    end
  #  end

  #  it 'recognizes a transposition on a 011 zero fund chart string' do
  #    assert_raise NucsErrors::TranspositionError do
  #      NucsValidator.new(zero_fund_chart_string.gsub('023-', '011-'), non_revenue_account).account_is_open!
  #    end
  #  end

  describe "ge001 validation" do
    let(:validator) { described_class.new(chart_string, account) }

    let(:fund) { "171" }
    let(:department) { "5401900" }
    let(:project) { "10006385" }
    let(:activity) { "01" }
    let(:program) { "1059" }
    let(:chartfield1) { "1095" }
    let(:chart_string) { [fund, department, project, activity, program, chartfield1].join("-") }

    describe "on revenue account" do
      let(:account) { revenue_account }

      it "validates a non-grant chart string on a revenue account" do
        define_ge001(chart_string)
        assert_nothing_raised do
          NucsValidator.new(chart_string, revenue_account).account_is_open!
        end
      end

      describe "bad fund" do
        let(:fund) { "166" }
        it { assert_unknown_ge001(validator, "fund") }
      end

      describe "bad department" do
        let(:department) { "5401922" }
        it { assert_unknown_ge001(validator, "department") }
      end

      describe "bad project" do
        let(:project) { "10006366" }
        it { assert_unknown_ge001(validator, "project") }
      end

      describe "bad activity" do
        let(:activity) { "02" }
        it { assert_unknown_ge001(validator, "activity") }
      end

      describe "bad program" do
        let(:program) { "1066" }
        it { assert_unknown_ge001(validator, "program") }
      end

      describe "bad chartfield1" do
        let(:chartfield1) { "2000" }
        it { assert_unknown_ge001(validator, "chart field 1") }
      end

      context "blank segments" do
        subject(:validator) { NucsValidator.new(chart_string, account) }
        before :each do
          allow(NucsFund).to receive(:find_by_value).with("110").and_return true
          allow(NucsDepartment).to receive(:find_by_value).with("5432300").and_return true
          allow(NucsProjectActivity).to receive(:find_by_project).with("10006385").and_return true
          allow(NucsProjectActivity).to receive(:find_by_activity).with("01").and_return true
          allow(NucsChartField1).to receive(:find_by_value).with("1025").and_return true
        end

        context "with several empty segments" do
          let(:chart_string) { "110-5432300----1025" }
          it { is_expected.to be_components_exist }
        end

        context "with missing program" do
          let(:chart_string) { "110-5432300-10006385-01--1025" }

          it "does finds the GE001 and never tries to find the blank program" do
            expect(NucsProgram).not_to receive(:find_by_value)
            expect(validator).to be_components_exist
          end
        end
      end
    end

    describe "with a non-revenue account" do
      let(:account) { non_revenue_account }

      it "validates a non-grant chart string on a non-revenue account" do
        define_gl066(chart_string)
        assert_nothing_raised do
          NucsValidator.new(chart_string, account).account_is_open!
        end
      end

      describe "bad fund" do
        let(:fund) { "170" }
        it { assert_unknown_gl066(validator) }
      end

      describe "bad department" do
        let(:department) { "5401910" }
        it { assert_unknown_gl066(validator) }
      end

      describe "bad project" do
        let(:project) { "10006366" }
        it { assert_unknown_gl066(validator) }
      end

      describe "bad program" do
        let(:program) { "2000" }
        it { assert_unknown_ge001(validator, "program") }
      end

      describe "bad chartfield1" do
        let(:chartfield1) { "2000" }
        it { assert_unknown_ge001(validator, "chart field 1") }
      end

      describe "without a project, or anything else" do
        let(:chart_string) { [fund, department].join("-")}
        it "does not require the project" do
          define_gl066(chart_string)
          NucsValidator.new(chart_string, account).account_is_open!
        end
      end
    end
  end

  # TODO I started refactoring this file, but only got about halfway through.

  it "recognizes an expired chart string on a GL066 entry with dates" do
    define_gl066(non_grant_chart_string, expires_at: Time.zone.today - 1)
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "recognizes an uninitiated chart string on a GL066 entry with dates" do
    define_gl066(non_grant_chart_string, starts_at: Time.zone.today + 1, expires_at: Time.zone.today + 1.year)
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "recognizes an expired chart string on a GL066 entry without dates" do
    define_gl066(non_grant_chart_string, budget_period: "2000")
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "does not raise an error if chart string is expired, compared with a prior fulfillment date, and is in 90 day window" do
    today = Time.zone.today
    define_gl066(non_grant_chart_string, expires_at: today - 1)
    assert_nothing_raised do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!((today - 2).to_datetime)
    end
  end

  it "does not raise an error if chart string has an expired and unexpired record and no fulfillment date is given." do
    today = Time.zone.today
    define_gl066(non_grant_chart_string, expires_at: today - 1.year)
    define_gl066(non_grant_chart_string, expires_at: today + 1.day)
    assert_nothing_raised do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "does raise an error if chart string is expired, compared with a post fulfillment date, and is in 90 day window" do
    today = Time.zone.today
    define_gl066(non_grant_chart_string, expires_at: today - 1)
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!(today.to_datetime)
    end
  end

  it "does raise an error if chart string is expired, compared with a prior fulfillment date, and is outside the 90 day window" do
    today = Time.zone.today
    Timecop.freeze today + 91.days do
      define_gl066(non_grant_chart_string, expires_at: today - 1)
      assert_raise NucsErrors::DatedGL066Error do
        NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!((today - 2).to_datetime)
      end
    end
  end

  it "validates a grant chart string on a non-revenue account" do
    define_open_account(non_revenue_account, grant_chart_string)
    assert_nothing_raised do
      NucsValidator.new(grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "requires an activity for a grant chart string on a non-revenue account" do
    define_open_account(non_revenue_account, grant_chart_string)
    assert_raise NucsErrors::InputError do
      chart_string = grant_chart_string[0...grant_chart_string.index("-01")]
      NucsValidator.new(chart_string, non_revenue_account).account_is_open!
    end
  end

  it "requires an activity for a non-grant chart string with project id on a non-revenue account" do
    define_open_account(non_revenue_account, non_grant_chart_string)
    assert_raise NucsErrors::InputError do
      chart_string = non_grant_chart_string[0...non_grant_chart_string.index("-01")]
      NucsValidator.new(chart_string, non_revenue_account).account_is_open!
    end
  end

  it "validates an activity for a grant chart string on a non-revenue account" do
    validator = NucsValidator.new(grant_chart_string.gsub("-01-", "-02-"), non_revenue_account)
    assert_unknown_gl066(validator, grant_chart_string, non_revenue_account)
  end

  it "confirms that an account is open for a chart string" do
    define_open_account(non_revenue_account, non_grant_chart_string)
    assert_nothing_raised do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "recognizes a missing budget tree" do
    FactoryGirl.create(:nucs_grants_budget_tree)
    define_gl066(grant_chart_string)
    assert_raise NucsErrors::UnknownBudgetTreeError do
      NucsValidator.new(grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "recognizes a closed account for a chart string" do
    define_open_account(non_revenue_account, non_grant_chart_string, {}, budget_period: "2000")
    assert_raise NucsErrors::DatedGL066Error do
      NucsValidator.new(non_grant_chart_string, non_revenue_account).account_is_open!
    end
  end

  it "confirms when all GE001 components are found" do
    define_ge001(non_grant_chart_string)
    validator = NucsValidator.new(non_grant_chart_string)
    expect(validator).to be_components_exist
  end

  it "acknowledges when a GE001 component is missing" do
    define_ge001(non_grant_chart_string)
    validator = NucsValidator.new(non_grant_chart_string.gsub("171-", "161-"))
    expect(validator).not_to be_components_exist
  end

  it "returns the later of matching expiration dates" do
    three_year_later = Time.zone.now + 3.years
    define_gl066(non_grant_chart_string, expires_at: three_year_later - 2.years)
    define_gl066(non_grant_chart_string, expires_at: three_year_later - 1.year)
    define_gl066(non_grant_chart_string, expires_at: three_year_later)
    expect(NucsValidator.new(non_grant_chart_string).latest_expiration.year).to eq(three_year_later.year)
  end

  it "returns nil when there is no match on components" do
    define_gl066(non_grant_chart_string, expires_at: Time.zone.now + 3.years)
    expect(NucsValidator.new(non_grant_chart_string.gsub("171-", "161-")).latest_expiration).to be_nil
  end

  it "returns nil when there is no project given, but one exists in the DB" do
    define_gl066(non_grant_chart_string, expires_at: Time.zone.now + 3.years)
    expect(NucsValidator.new(non_grant_chart_string[0...non_grant_chart_string.index("-10006385")]).latest_expiration).to be_nil
  end

  it 'returns a date when there is no project given and "-" exists in the DB' do
    define_gl066(non_grant_chart_string,       expires_at: Time.zone.now + 3.years,
                                     project: NucsValidator::NUCS_BLANK,
                                     activity: NucsValidator::NUCS_BLANK)

    expect(NucsValidator.new(non_grant_chart_string[0...non_grant_chart_string.index("-10006385")]).latest_expiration).not_to be_nil
  end

  it 'returns a date when there is no activity given and "-" exists in the DB' do
    define_gl066(non_grant_chart_string, expires_at: Time.zone.now + 3.years, activity: NucsValidator::NUCS_BLANK)
    expect(NucsValidator.new(non_grant_chart_string[0...non_grant_chart_string.index("-01")]).latest_expiration).not_to be_nil
  end

  it "returns nil when the matching GL066 entry is expired" do
    define_gl066(non_grant_chart_string, expires_at: Time.zone.now - 1.year)
    expect(NucsValidator.new(non_grant_chart_string).latest_expiration).to be_nil
  end

  it "errors on blacklisted fund" do
    Blacklist::DISALLOWED_FUNDS.each do |fund|
      blacklisted = non_grant_chart_string.gsub("171-", "#{fund}-")
      assert_raise NucsErrors::BlacklistedError do
        NucsValidator.new(blacklisted)
      end
    end
  end

  it "errors on blacklisted account" do
    %w(0 1 2 3 4 6 8 9).each do |i|
      blacklisted = i + revenue_account[1..-1]
      assert_raise NucsErrors::BlacklistedError do
        NucsValidator.new(non_grant_chart_string, blacklisted)
      end
    end
  end

  #
  # Test AcctngChartStringConstructionRules.pdf logic in #validate_gl066_PAD_components!
  #

  it "does not allow a project when fund >= 100 and <= 169" do
    chart_string = grant_chart_string.gsub("191-", "111-")
    define_open_account(non_revenue_account, chart_string)

    assert_raise NucsErrors::NotAllowedError do
      NucsValidator.new(chart_string, non_revenue_account).account_is_open!
    end
  end

  it "does not allow a project that does not start with 1 when fund >= 170 and <= 179" do
    assert_project_input_error grant_chart_string.gsub("191-", "175-")
  end

  it "does not allow a project that does not start with 6 when fund >= 191 and <= 199" do
    assert_project_input_error grant_chart_string.gsub("60006385", "40006385")
  end

  it "does not allow a project that does not start with 3 when fund >= 300 and <= 320" do
    assert_project_input_error grant_chart_string.gsub("191-", "315-")
  end

  it "does not allow an activity other than 01 when fund is >= 410 and <= 483" do
    chart_string = grant_chart_string.gsub("191-", "411-").gsub("-01-", "-02-")
    define_open_account(non_revenue_account, chart_string)

    exception = assert_raise NucsErrors::InputError do
      NucsValidator.new(chart_string, non_revenue_account).account_is_open!
    end

    expect(exception.message).to be_end_with "activity"
  end

  it "does not allow a project that does not start with 5 when fund >= 500 and <= 540" do
    assert_project_input_error grant_chart_string.gsub("191-", "505-")
  end

  it "does not allow a project that does not start with 6 when fund >= 600 and <= 650" do
    assert_project_input_error grant_chart_string.gsub("191-", "605-").gsub("60006385", "40006385")
  end

  it "does not allow a project that does not start with 7 when fund >= 700 and <= 740" do
    assert_project_input_error grant_chart_string.gsub("191-", "701-")
  end

  it "does not allow a project that does not start with 7 when fund is 750" do
    assert_project_input_error grant_chart_string.gsub("191-", "750-")
  end

  it "does not allow a project that does not start with 8 when fund >= 800 and <= 840" do
    assert_project_input_error grant_chart_string.gsub("191-", "810-")
  end

  it "considers whitelisted chart strings always open" do
    validator = NucsValidator.new(Whitelist::ALLOWED_CHART_STRINGS[0], non_revenue_account)
    assert_nothing_raised { validator.account_is_open! }
  end

  def assert_project_input_error(chart_string)
    define_open_account(non_revenue_account, chart_string)

    exception = assert_raise NucsErrors::InputError do
      NucsValidator.new(chart_string, non_revenue_account).account_is_open!
    end

    expect(exception.message).to be_end_with "project"
  end

  def assert_unknown_gl066(validator, chart_string = non_grant_chart_string, account = nil)
    if account
      define_open_account(account, chart_string)
    else
      define_gl066(chart_string)
    end

    assert_raise NucsErrors::UnknownGL066Error do
      validator.account_is_open!
    end
  end

  def assert_unknown_ge001(validator, failed_component_name, chart_string = non_grant_chart_string)
    define_ge001(chart_string)

    begin
      validator.account_is_open!
    rescue NucsErrors::UnknownGE001Error => e
      expect(e.message).to be_end_with(failed_component_name)
    else
      assert false, "Did not receive UnknownGE001 for #{failed_component_name}"
    end
  end
end
