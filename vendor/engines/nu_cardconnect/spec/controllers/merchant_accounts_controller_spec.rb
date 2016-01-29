require "rails_helper"

RSpec.describe NuCardconnect::MerchantAccountsController do
  let(:facility) { FactoryGirl.create(:facility) }
  let(:admin) { FactoryGirl.create(:user, :administrator) }
  let(:director) { FactoryGirl.create(:user, :facility_director, facility: facility) }

  describe "edit" do
    def do_request
      get :edit, facility_id: facility.url_name
    end

    describe "not logged in" do
      it "does not allow access" do
        do_request
        expect(response.status).to eq(302)
      end
    end

    describe "logged in as a director" do
      before { sign_in director }

      it "does not allow access" do
        do_request
        expect(response.status).to eq(403)
      end
    end

    describe "as a global admin" do
      before { sign_in admin }

      it "allows access" do
        do_request
        expect(response).to be_success
      end
    end
  end

  describe "update" do
    let(:params) {}

    def do_request
      put :update, facility_id: facility.url_name, nu_cardconnect_merchant_account: params
    end

    describe "not logged in" do
      it "does not allow access" do
        do_request
        expect(response.status).to eq(302)
      end
    end

    describe "logged in as a director" do
      before { sign_in director }

      it "does not allow access" do
        do_request
        expect(response.status).to eq(403)
      end
    end

    describe "as a global admin" do
      before { sign_in admin }

      describe "success" do
        let(:params) { { card_connect_merchant_id: 123456 } }

        it "saves to the fields" do
          do_request
          expect(facility.reload.card_connect_merchant_id).to eq("123456")
        end

        it "redirects and sets the flash" do
          do_request
          expect(response.status).to eq(302)
          expect(controller).to set_flash
        end
      end

      describe "success, but with illegal fields" do
        let(:params) { { card_connect_merchant_id: 123456, abbreviation: "ABC" } }

        it "does not change the abbreviation" do
          expect { do_request }.not_to change { facility.reload.abbreviation }
        end
      end
    end
  end
end
