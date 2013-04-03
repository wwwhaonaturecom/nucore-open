require 'spec_helper'

describe FacilityAccount do
  context 'revenue_account' do
    it 'should allow numbers starting with 4' do
      fa = FacilityAccount.new(:revenue_account => '41234')
      fa.valid?
      fa.errors.should_not include :revenue_account
    end
    it 'should allow numbers starting with 5'  do
      fa = FacilityAccount.new(:revenue_account => '51234')
      fa.valid?
      fa.errors.should_not include :revenue_account
    end
    it 'should not allow numbers starting with 7' do
      fa = FacilityAccount.new(:revenue_account => '71234')
      fa.valid?
      fa.errors.should include :revenue_account
    end

    it 'should not allow numbers starting with 4, but are too short' do
      fa = FacilityAccount.new(:revenue_account => '41')
      fa.valid?
      fa.errors.should include :revenue_account
    end

    it 'should not allow numbers starting with 4, but are too long' do
      fa = FacilityAccount.new(:revenue_account => '412345')
      fa.valid?
      fa.errors.should include :revenue_account
    end
  end
end
