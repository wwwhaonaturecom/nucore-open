require "rails_helper"

RSpec.describe NuCardconnect::PaymentsController do
  let(:facility) { FactoryGirl.create(:facility, card_connect_merchant_id: merchant_id) }
  let(:merchant_id) { 123456 }
  let(:user) { FactoryGirl.create(:user) }
  let(:account) { FactoryGirl.create(:purchase_order_account, :with_account_owner, owner: user) }
  let(:statement) { FactoryGirl.create(:statement, facility: facility, account: account, created_by_user: user) }

  describe "#pay" do
    it "does not allow access by id" do
      get :pay, uuid: statement.id
      expect(response.status).to eq(404)
    end

    it "accesses by UUID" do
      get :pay, uuid: statement.uuid
      expect(response).to be_success
      expect(assigns(:statement)).to eq(statement)
    end
  end

  describe "#process" do
    before { allow(SettingsHelper).to receive(:setting).with("cardconnect.percentage").and_return(4) }
    # This avoids needing to set up OrderDetails
    before { allow_any_instance_of(Statement).to receive(:total_cost).and_return 10.00 }
    before { sign_in user }

    describe "success" do
      before do
        allow_any_instance_of(NuCardconnect::Authorization).to receive(:capture).and_return true
        allow_any_instance_of(NuCardconnect::Authorization).to receive(:id).and_return "123456"
      end

      it "marks the statement as paid" do
        expect { post :process_payment, uuid: statement.uuid, payment: {} }
          .to change { statement.reload.paid_in_full? }.to(true)
      end

      it "captures the processing fee separately" do
        post :process_payment, uuid: statement.uuid, payment: {}
        payment = Payment.last
        expect(payment.amount).to eq(10)
        expect(payment.processing_fee).to eq(0.4)
      end

      it "captures the current user if they are signed in" do
        sign_in user
        post :process_payment, uuid: statement.uuid, payment: {}
        expect(Payment.last.paid_by).to eq(user)
      end
    end

    describe "already paid" do
      let!(:payment) { Payment.create!(statement: statement, account: account, source: :cardconnect, amount: 100.00) }

      it "does not try to capture the payment" do
        expect_any_instance_of(NuCardconnect::Authorization).not_to receive(:capture)
        post :process_payment, uuid: statement.uuid, payment: {}
        expect(flash.now[:error]).to eq(I18n.t("nu_cardconnect.process.already_paid"))
      end
    end

    describe "facility does not have a merchant id" do
      let(:merchant_id) { nil }

      it "does not allow payment" do
        expect_any_instance_of(NuCardconnect::Authorization).not_to receive(:capture)
        post :process_payment, uuid: statement.uuid, payment: {}
        expect(flash.now[:error]).to eq(I18n.t("nu_cardconnect.process.no_merchant_id"))
      end
    end

    describe "failure" do
      before do
        allow_any_instance_of(NuCardconnect::Authorization).to receive(:capture).and_return false
        allow_any_instance_of(NuCardconnect::Authorization).to receive(:errors).and_return ["Error"]
      end

      it "does not mark the stament as paid_in_full" do
        expect { post :process_payment, uuid: statement.uuid, payment: {} }
          .not_to change { statement.reload.paid_in_full? }
      end
    end
  end
end
