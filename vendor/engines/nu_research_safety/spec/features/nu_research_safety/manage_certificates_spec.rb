require "rails_helper"

RSpec.describe "Managing Certificates" do
  before { login_as administrator }

  let(:administrator) { FactoryGirl.create(:user, :administrator) }
  let!(:certificate) { FactoryGirl.create(:certificate) }

  describe "adding a new certificate" do
    before do
      visit certificates_path
      click_link "Add Certificate"
      fill_in "nu_research_safety_certificate[name]", with: "Test"
      click_button "Create Certificate"
    end

    it "adds the certificate" do
      expect(current_path).to eq certificates_path
      expect(page).to have_content("Certificate Test created")
    end
  end

  describe "editing a certificate", :aggregate_failures do
    before do
      visit certificates_path
      click_link "Edit Certificate"
      fill_in "nu_research_safety_certificate[name]", with: "Edited-#{certificate.id}"
      click_button "Update Certificate"
    end

    it "updates the certificate" do
      expect(current_path).to eq certificates_path
      expect(page).to have_content("Certificate Edited-#{certificate.id} updated")
    end
  end

  describe "deleting a certificate", :aggregate_failures do
    before do
      visit certificates_path
      click_link "Remove"
    end

    it "deletes the certificate", :aggregate_failures do
      expect(current_path).to eq certificates_path
      expect(page).to have_content("Certificate #{certificate.name} removed")
    end
  end
end
