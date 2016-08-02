require "rails_helper"

RSpec.describe "Purchasing a Sequencing service from ACGT", :aggregate_failures do
  include RSpec::Matchers.clone # Give RSpec's `all` precedence over Capybara's

  let(:facility) { FactoryGirl.create(:setup_facility) }
  let!(:service) { FactoryGirl.create(:setup_service, facility: facility) }
  let!(:account) { FactoryGirl.create(:nufs_account, :with_account_owner, owner: user) }
  let!(:price_policy) { FactoryGirl.create(:service_price_policy, price_group: PriceGroup.base.first, product: service) }
  let(:user) { FactoryGirl.create(:user) }
  let(:external_service) { create(:external_service, location: new_sanger_sequencing_submission_path) }
  let!(:sanger_order_form) { create(:external_service_passer, external_service: external_service, active: true, passer: service) }
  let!(:account_price_group_member) do
    FactoryGirl.create(:account_price_group_member, account: account, price_group: price_policy.price_group)
  end

  shared_examples_for "purchasing a sanger product and filling out the form" do
    def input_selector(field)
      ".nested_sanger_sequencing_submission_samples input[name*=#{field}]"
    end

    let(:quantity) { 5 }
    let(:customer_id_selector) { input_selector("customer_sample_id") }
    let(:cart_quantity_selector) { ".edit_order input[name^=quantity]" }
    before do
      visit facility_service_path(facility, service)
      click_link "Add to cart"
      choose account.to_s
      click_button "Continue"
      find(cart_quantity_selector).set(quantity.to_s)
      click_button "Update"
      click_link "Complete Online Order Form"
    end

    it "saves the form with all the extra fields" do
      page.first(customer_id_selector).set("TEST123")
      page.first(input_selector("template_concentration")).set("12345")
      page.first(input_selector("high_gc")).set(true)
      page.first(input_selector("hair_pin")).set(true)
      page.first("select[name*=template_type] option[value=Plasmid]").select_option
      page.first(input_selector("pcr_product_size")).set("543")
      page.first(input_selector("primer_name")).set("primer1")
      page.first(input_selector("primer_concentration")).set("963")
      click_button "Save Submission"

      sample = SangerSequencing::Sample.find_by(customer_sample_id: "TEST123")
      expect(sample.template_concentration).to eq(12345)
      expect(sample.template_type).to eq("Plasmid")
      expect(sample.pcr_product_size).to eq(543)
      expect(sample.primer_name).to eq("primer1")
      expect(sample.primer_concentration).to eq(963)
      expect(sample).to be_high_gc
      expect(sample).to be_hair_pin
      expect(SangerSequencing::Sample.count).to eq(5)
    end

    describe "saving and returning to the form" do
      before do
        page.first(customer_id_selector).set("TEST123")
        click_button "Save Submission"
        click_link "Edit Online Order Form"
      end

      it "returns to the form" do
        expect(page.first(customer_id_selector).value).to eq("TEST123")
      end
    end

    describe "after purchasing" do
      before do
        page.first(customer_id_selector).set("TEST123")
        click_button "Save Submission"
        click_button "Purchase"
        expect(Order.first).to be_purchased
      end

      it "can show, but not edit" do
        visit sanger_sequencing_submission_path(SangerSequencing::Submission.last)
        expect(page.status_code).to eq(200)

        visit edit_sanger_sequencing_submission_path(SangerSequencing::Submission.last)
        expect(page.status_code).to eq(404)
      end

      it "renders the sample ID on the receipt" do
        expect(page).to have_content "Receipt"
        expect(page).to have_content "TEST123"
      end
    end
  end

  describe "as a normal user" do
    before do
      login_as user
    end

    it_behaves_like "purchasing a sanger product and filling out the form"
  end

  describe "while acting as another user" do
    let(:admin) { FactoryGirl.create(:user, :administrator) }
    before do
      login_as admin
      visit facility_user_switch_to_path(facility, user)
    end

    it_behaves_like "purchasing a sanger product and filling out the form"
  end
end
