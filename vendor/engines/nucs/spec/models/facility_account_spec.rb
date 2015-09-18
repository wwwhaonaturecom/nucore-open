require 'spec_helper'

RSpec.describe FacilityAccount do
  context 'revenue_account' do
    it 'should allow numbers starting with 4' do
      expect(subject).to allow_value('41234').for(:revenue_account)
    end

    it 'should allow numbers starting with 5'  do
      expect(subject).to allow_value('51234').for(:revenue_account)
    end

    it 'should not allow numbers starting with 7' do
      expect(subject).not_to allow_value('71234').for(:revenue_account)
    end

    it 'should not allow numbers starting with 4, but are too short' do
      expect(subject).not_to allow_value('41').for(:revenue_account)
    end

    it 'should not allow numbers starting with 4, but are too long' do
      expect(subject).not_to allow_value('412345').for(:revenue_account)
    end

    it 'should allow an exception for 78767' do
      expect(subject).to allow_value('78767').for(:revenue_account)
    end
  end
end
