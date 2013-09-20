require 'spec_helper'
require 'controller_spec_helper'

describe FacilityAccountsController do
  before(:all) { create_users }
  before :each do
    @authable=FactoryGirl.create(:facility)
    @facility_account=FactoryGirl.create(:facility_account, :facility => @authable)
  end

  describe 'create' do
    let(:base_account_fields) do
      { :fund => "901",
        :dept => "7777777",
        :project => "50028814",
        :activity => "01",
        :program => '',
        :chart_field1 => '' }
    end

    let(:base_account_number) { "901-7777777-50028814-01" }
    before :each do
      sign_in @admin
      @method = :post
      @action = :create
      @params = {
        :facility_id => @authable.url_name,
        :owner_user_id => @guest.id,
        :class_type => 'NufsAccount'
      }
    end

    context 'entering a four digit project' do
      before :each do
        @params.merge!(:account => { :description => 'description', :account_number_parts => {:fund => '901', :dept => '7777777', :project => '1234' }})
        do_request
      end

      it 'should not save' do
        assigns(:account).should_not be_persisted
        expect(assigns(:account).errors.full_messages).to include("901-7777777-1234 is invalid for chart string")
      end
    end

    context 'without a project, but with an activity' do
      before :each do
        @params.merge!(:account => { :description => 'description', :account_number_parts => {:fund => '901', :dept => '7777777', :activity => '12' }})
        do_request
      end

      it 'should not save' do
        assigns(:account).should_not be_persisted
        expect(assigns(:account).errors.full_messages).to include("901-7777777--12 is invalid for chart string")
      end
    end

    context 'without a program or chart_field1' do
      before :each do
        define_gl066 base_account_number
        @params.merge!(:account => {
          :description => 'Description',
          :account_number_parts => base_account_fields
        })
        do_request
      end

      it 'should be persisted' do
        assigns(:account).should be_persisted
      end

      it 'should set the number' do
        assigns(:account).account_number.should == base_account_number
      end

      it 'should set the display' do
        assigns(:account).to_s.should include base_account_number
      end
    end

    context 'with a program' do
      before :each do
        define_gl066 base_account_number + "-1234"
        @params.merge!(:account => {
          :description => 'Description',
          :account_number_parts => base_account_fields.merge(:program => '1234')
        })
        do_request
      end

      it 'should be persisted' do
        assigns(:account).should be_persisted
      end

      it 'should set the number' do
        assigns(:account).account_number.should == base_account_number + "-1234-"
      end

      it 'should set the display' do
        assigns(:account).to_s.should include "#{base_account_number} (1234) ()"
      end
    end

    context 'with a chart_field1' do
      before :each do
        define_gl066 base_account_number + "--1234"
        @params.merge!(:account => {
          :description => 'Description',
          :account_number_parts => base_account_fields.merge(:chart_field1 => '1234')
        })
        do_request
      end

      it 'should be persisted' do
        assigns(:account).should be_persisted
      end

      it 'should set the number' do
        assigns(:account).account_number.should == base_account_number + "--1234"
      end

      it 'should set the display' do
        assigns(:account).to_s.should include "#{base_account_number} () (1234)"
      end
    end

    context 'with a program AND chart_field1' do
      before :each do
        define_gl066 base_account_number + "-6543-1234"
        @params.merge!(:account => {
          :description => 'Description',
          :account_number_parts => base_account_fields.merge(:program => '6543', :chart_field1 => '1234')
        })
        do_request
      end

      it 'should be persisted' do
        assigns(:account).should be_persisted
      end


      it 'should set the number' do
        assigns(:account).account_number.should == base_account_number + "-6543-1234"
      end

      it 'should set the display' do
        assigns(:account).to_s.should include "#{base_account_number} (6543) (1234)"
      end
    end
  end
end
