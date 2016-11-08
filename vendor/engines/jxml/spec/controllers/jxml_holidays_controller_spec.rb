require "rails_helper"

RSpec.describe JxmlHolidaysController do
  describe "as a normal user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    it "does not give access to index" do
      get :index
      expect(response.code).to eq("403")
    end

    it "does not give access to create" do
      post :create, jxml_holiday: { date: 1.month.ago }
      expect(response.code).to eq("403")
    end

    it "does not give access to update" do
      holiday = JxmlHoliday.create(date: 1.month.from_now)
      put :update, id: holiday.id, jxml_holiday: {}
      expect(response.code).to eq("403")
    end
  end

  describe "as a global admin" do
    let(:user) { FactoryGirl.create(:user, :administrator) }
    before { sign_in user }

    describe "#new" do
      it "renders template" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "#create" do
      def do_request
        post :create, jxml_holiday: { date: date }
      end

      describe "success" do
        describe "with a string param" do
          let(:date) { "06/10/2016" }

          it "interprets month/day correctly" do
            do_request
            expect(JxmlHoliday.last.date).to eq(Time.zone.parse("2016-06-10"))
          end
        end
      end

      describe "with an empty date" do
        let(:date) { "" }

        it "does not create a new holiday" do
          expect { do_request }.not_to change(JxmlHoliday, :count)
        end

        it "renders the form again" do
          do_request
          expect(response).to render_template :new
        end
      end
    end

    describe "#update" do
      let!(:jxml_holiday) { JxmlHoliday.create(date: 1.month.from_now) }

      def do_request
        put :update, id: jxml_holiday.id, jxml_holiday: { date: new_date }
      end

      describe "success" do
        let(:new_date) { "11/20/2016" }

        it "updates the model" do
          expect { do_request }.to change { jxml_holiday.reload.date }.to(Time.zone.parse("2016-11-20"))
        end
      end

      describe "failure" do
        let(:new_date) { "" }

        it "does not update the model" do
          expect { do_request }.not_to change { jxml_holiday.reload.date }
        end

        it "renders the edit view again" do
          do_request
          expect(response).to render_template :edit
          expect(assigns(:jxml_holiday)).to eq(jxml_holiday)
        end
      end
    end

    describe "#destroy" do
      let!(:jxml_holiday) { JxmlHoliday.create(date: 1.month.from_now) }

      it "destroys the holiday" do
        expect { delete :destroy, id: jxml_holiday.id }.to change(JxmlHoliday, :count).by(-1)
      end
    end
  end
end
