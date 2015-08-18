require 'spec_helper'
require 'controller_spec_helper'
require 'transaction_search_spec_helper'

describe FacilityJournalsController do
  include DateHelper

  render_views

  before(:all) { create_users }

  before(:each) do
    @authable = FactoryGirl.create(:facility)
    @account = FactoryGirl.create(:nufs_account, account_users_attributes: account_users_attributes_hash(user: @admin), facility_id: @authable.id)
    @journal = FactoryGirl.create(:journal, facility: @authable, created_by: @admin.id, journal_date: Time.current)
  end

  context 'create' do
    before :each do
      @method = :post
      @action = :create
      @journal_date = I18n.l(Date.current, format: :usa)
      @params = {
        :facility_id => @authable.url_name,
        :journal_date => @journal_date
      }
    end

    context 'with order detail' do
      before :each do
        acct = create_nufs_account_with_owner :director
        place_and_complete_item_order(@director, @authable, acct)
        define_open_account(@item.account, acct.account_number)
        @params.merge!(order_detail_ids: [ @order_detail.id ])
      end

      it 'allows director to create the journal' do
        maybe_grant_always_sign_in(:director)
        do_request

        expect(assigns(:journal).errors.full_messages).to eq([])
        expect(assigns(:journal)).to be_persisted
        expect(assigns(:journal).created_by).to eq(@director.id)
        expect(assigns(:journal).journal_date).to eq(parse_usa_date(@journal_date))
        expect(assigns(:journal).journal_rows).not_to be_empty

        should set_the_flash
        assert_redirected_to facility_journals_path
      end

    end

  end

end
