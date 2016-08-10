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

  def input_selector(field)
    ".nested_sanger_sequencing_submission_samples input[name*=#{field}]"
  end

  def fill_in_first_row
    page.first(customer_id_selector).set("TEST123")
    page.first(input_selector("template_concentration")).set("12345")
    page.first(input_selector("high_gc")).set(true)
    page.first(input_selector("hair_pin")).set(true)
    page.first("select[name*=template_type] option[value=Plasmid]").select_option
    page.first(input_selector("pcr_product_size")).set("543")
    page.first(input_selector("primer_name")).set("primer1")
    page.first(input_selector("primer_concentration")).set("963")
  end

  let(:quantity) { 5 }
  let(:customer_id_selector) { input_selector("customer_sample_id") }
  let(:cart_quantity_selector) { ".edit_order input[name^=quantity]" }

  before do
    login_as user
    visit facility_service_path(facility, service)
    click_link "Add to cart"
    choose account.to_s
    click_button "Continue"
    find(cart_quantity_selector).set(quantity.to_s)
    click_button "Update"
    click_link "Complete Online Order Form"
  end

  it "saves the form with all the extra fields" do
    fill_in_first_row
    click_button "Save Submission"

    sample = SangerSequencing::Sample.find_by(customer_sample_id: "TEST123")
    expect(sample.template_concentration).to eq(12345)
    expect(sample.template_type).to eq("Plasmid")
    expect(sample.pcr_product_size).to eq(543)
    expect(sample.primer_name).to eq("primer1")
    expect(sample.primer_concentration).to eq(963)
    expect(sample).to be_high_gc
    expect(sample).to be_hair_pin
    expect(sample.well_position).to be_blank
    expect(SangerSequencing::Sample.count).to eq(5)
  end

  describe "filling in with the fill buttons", :js do
    before do
      fill_in_first_row
      page.all(".js--sangerFillColumnFromFirst, .js--sangerCheckAll").each { |btn| btn.click }
      click_button "Save Submission"
    end

    it "fills in all the fields with the first row's data" do
      samples = SangerSequencing::Sample.all
      expect(samples.map(&:template_concentration)).to all(eq(12345))
      expect(samples).to all(be_high_gc)
      expect(samples).to all(be_hair_pin)
      expect(samples.map(&:template_type)).to all(eq("Plasmid"))
      expect(samples.map(&:pcr_product_size)).to all(eq(543))
      expect(samples.map(&:primer_name)).to all(eq("primer1"))
      expect(samples.map(&:primer_concentration)).to all(eq(963))
    end
  end

  describe "in plate mode", :js do
    let(:quantity) { 2 }
    before { click_link "Submit as a plate" }

    it "supports the various plate mode features" do
      # Starting place
      expect(page).to have_content("A01")
      expect(page).to have_content("B01")

      # Adding a row
      expect(page).not_to have_content("C01")
      click_link "Add"
      expect(page).to have_content("C01")

      # Toggling fill order
      click_link "Fill by columns"

      expect(page).to have_content("A01")
      expect(page).to have_content("A02")
      expect(page).to have_content("A03")

      # Saving
      click_button "Save Submission"
      expect(SangerSequencing::Sample.pluck(:well_position)).to eq(["A01", "A02", "A03"])
    end
  end

  describe "adding another row", :js do
    let(:quantity) { 1 }

    before do
      fill_in_first_row
      click_link "Add"
      # wait until the new row is ready
      expect(page).to have_css("#{customer_id_selector}:enabled", count: 2)
      click_button "Save Submission"
    end

    it "fills in all the fields with the first row's data" do
      samples = SangerSequencing::Sample.all
      expect(samples.size).to eq(2)
      expect(samples.map(&:template_concentration)).to all(eq(12345))
      expect(samples).to all(be_high_gc)
      expect(samples).to all(be_hair_pin)
      expect(samples.map(&:template_type)).to all(eq("Plasmid"))
      expect(samples.map(&:pcr_product_size)).to all(eq(543))
      expect(samples.map(&:primer_name)).to all(eq("primer1"))
      expect(samples.map(&:primer_concentration)).to all(eq(963))
    end
  end
end
