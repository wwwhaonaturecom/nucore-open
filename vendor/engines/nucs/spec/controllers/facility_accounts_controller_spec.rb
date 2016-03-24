require "rails_helper"
require "controller_spec_helper"

RSpec.describe FacilityAccountsController do
  before(:all) { create_users }
  before :each do
    @authable = FactoryGirl.create(:facility)
    @facility_account = FactoryGirl.create(:facility_account, facility: @authable)
  end

  describe "create" do
    let(:base_account_fields) do
      { fund: "901",
        dept: "7777777",
        project: "50028814",
        activity: "01",
        program: "",
        chart_field1: "" }
    end

    let(:base_account_number) { "901-7777777-50028814-01" }
    before :each do
      sign_in @admin
      @method = :post
      @action = :create
      @params = {
        facility_id: @authable.url_name,
        owner_user_id: @guest.id,
        account_type: "NufsAccount",
        nufs_account: account_params,
      }
    end

    let(:account_params) { { description: "description", account_number_parts: account_number_parts } }

    context "entering a four digit project" do
      let(:account_number_parts) { { fund: "901", dept: "7777777", project: "1234" } }

      before :each do
        do_request
      end

      it "should not save" do
        expect(assigns(:account)).not_to be_persisted
        expect(assigns(:account).errors.full_messages).to include("Project is the wrong length (should be 8 characters)")
      end

      it "does not have an expiration warning" do
        expect(assigns(:account).errors.full_messages).not_to include(a_string_starting_with("Expiration"))
      end
    end

    context "without a project, but with an activity" do
      let(:account_number_parts) { { fund: "901", dept: "7777777", activity: "12" } }
      before :each do
        do_request
      end

      it "should not save" do
        expect(assigns(:account)).not_to be_persisted
        expect(assigns(:account).errors.full_messages).to include("Project can't be blank")
      end
    end

    context "without a program or chart_field1" do
      let(:account_number_parts) { base_account_fields }
      before :each do
        define_gl066 base_account_number
        do_request
      end

      it "should be persisted" do
        expect(assigns(:account)).to be_persisted
      end

      it "should set the number" do
        expect(assigns(:account).account_number).to eq(base_account_number)
      end

      it "should set the display" do
        expect(assigns(:account).to_s).to include base_account_number
      end
    end

    context "with a program" do
      let(:account_number_parts) { base_account_fields.merge(program: "1234") }
      before :each do
        define_gl066 base_account_number + "-1234"
        do_request
      end

      it "should be persisted" do
        expect(assigns(:account)).to be_persisted
      end

      it "should set the number" do
        expect(assigns(:account).account_number).to eq(base_account_number + "-1234")
      end

      it "should set the display" do
        expect(assigns(:account).to_s).to include "#{base_account_number} (1234) ()"
      end
    end

    context "with a chart_field1" do
      let(:account_number_parts) { base_account_fields.merge(chart_field1: "1234") }
      before :each do
        define_gl066 base_account_number + "--1234"
        do_request
      end

      it "should be persisted" do
        expect(assigns(:account)).to be_persisted
      end

      it "should set the number" do
        expect(assigns(:account).account_number).to eq(base_account_number + "--1234")
      end

      it "should set the display" do
        expect(assigns(:account).to_s).to include "#{base_account_number} () (1234)"
      end
    end

    context "with a program AND chart_field1" do
      let(:account_number_parts) { base_account_fields.merge(program: "6543", chart_field1: "1234") }
      before :each do
        define_gl066 base_account_number + "-6543-1234"
        do_request
      end

      it "should be persisted" do
        expect(assigns(:account)).to be_persisted
      end

      it "should set the number" do
        expect(assigns(:account).account_number).to eq(base_account_number + "-6543-1234")
      end

      it "should set the display" do
        expect(assigns(:account).to_s).to include "#{base_account_number} (6543) (1234)"
      end
    end

    context "with a blacklisted fund" do
      let(:account_number_parts) { base_account_fields.merge(fund: "011") }

      it "should include an error" do
        do_request
        expect(assigns(:account)).to be_new_record
        expect(assigns(:account).errors.full_messages).to include("011 is blacklisted as a fund")
      end
    end

    context "with an non-existing GL066" do
      let(:account_number_parts) { base_account_fields }

      it "should include errors", :aggregate_failures do
        do_request
        expect(assigns(:account)).to be_new_record
        expect(assigns(:account).errors.full_messages).to include("The chart string appears to be invalid. Either the fund, department, project, or activity could not be found.")
        expect(assigns(:account).errors.full_messages).not_to include(a_string_starting_with("Expiration"))
      end
    end
  end
end
