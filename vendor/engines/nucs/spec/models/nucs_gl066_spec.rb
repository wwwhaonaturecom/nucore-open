require 'spec_helper'
require 'nucs_spec_helper'

describe NucsGl066 do

  { :fund => [3, 5], :department => [7, 10] }.each do |k, v|
    min, max=v[0], v[1]
    it { is_expected.not_to allow_value(mkstr(min-1)).for(k) }
    it { is_expected.not_to allow_value(mkstr(max+1)).for(k) }
    it { is_expected.not_to allow_value(mkstr(min, 'a')).for(k) }
    it { is_expected.not_to allow_value('-').for(k) }
    it { is_expected.to allow_value(mkstr(min)).for(k) }
    it { is_expected.to allow_value(mkstr(min, 'B')).for(k) }
    it { is_expected.to allow_value(mkstr((min/2.0).ceil, 'A1')).for(k) }
  end


  { :budget_period => [4, 8], :project => [8, 15], :activity => [2, 15], :account => [5, 10] }.each do |k, v|
    min, max=v[0], v[1]
    it { is_expected.not_to allow_value('^').for(k) }
    it { is_expected.not_to allow_value(mkstr(min-1)).for(k) }
    it { is_expected.not_to allow_value(mkstr(max+1)).for(k) }
    it { is_expected.not_to allow_value(mkstr(min, 'a')).for(k) }
    it { is_expected.to allow_value('-').for(k) }
    it { is_expected.to allow_value(mkstr(min)).for(k) }
  end


  [ :starts_at, :expires_at ].each do |method|
    it { is_expected.to have_db_column(method).of_type(:datetime) }
    it { is_expected.to allow_value(nil).for(method) }
  end


  it "should give a Time based on budget_period even when starts_at column value is null" do
    gl=FactoryGirl.create(:nucs_gl066_without_dates)
    date=gl.starts_at
    expect(date).to be_a_kind_of(Time)
    expect(date).to eq(Time.zone.parse("#{gl.budget_period}0901")-1.year)
  end


  it "should give a Time based on starts_at even when expires_at column value is null" do
    gl=FactoryGirl.create(:nucs_gl066_without_dates)
    date=gl.expires_at
    expect(date).to be_a_kind_of(Time)
    expect(date).to eq(gl.starts_at + 1.year - 1.second)
  end


  it 'should tell us when now is before a starts_at date' do
    gl=FactoryGirl.create(:nucs_gl066_with_dates, { :starts_at => Time.zone.now+5.day, :expires_at => Time.zone.now+8.day})
    expect(gl).to be_expired
  end


  it 'should tell us when now is after a expires_at date' do
    gl=FactoryGirl.create(:nucs_gl066_with_dates, { :starts_at => Time.zone.now-5.day, :expires_at => Time.zone.now-2.day})
    expect(gl).to be_expired
  end


  it 'should tell us when now is in a starts_at and expires_at window' do
    gl=FactoryGirl.create(:nucs_gl066_with_dates, { :starts_at => Time.zone.now-3.day, :expires_at => Time.zone.now+3.day})
    expect(gl).not_to be_expired
  end


  it 'should tell us when now on starts_at' do
    gl=FactoryGirl.create(:nucs_gl066_with_dates, { :starts_at => Time.zone.now, :expires_at => Time.zone.now+3.day})
    expect(gl).not_to be_expired
  end


  it 'should tell us when now on expires_at' do
    gl=FactoryGirl.create(:nucs_gl066_with_dates, { :starts_at => Time.zone.now-3.day, :expires_at => Time.zone.now.end_of_day})
    expect(gl).not_to be_expired
  end


  it "should raise an ImportError on malformed source lines" do
    assert_raises NucsErrors::ImportError do
      NucsGl066.tokenize_source_line('-|156|2243550|-|-|-||')
    end
  end


  it "should return an invalid record when creating from a valid source line with invalid data" do
    tokens=NucsGl066.tokenize_source_line('2010|171|4011100|XXXXXXXX|-|-||')
    gl=NucsGl066.create_from_source(tokens)
    expect(gl).to be_new_record
    expect(gl).not_to be_valid
  end


  context 'tokenize_source_line' do

    shared_context 'tokens' do |expected_count|
      it 'tokenizes without error' do
        expect(tokens).to be_a Array
        expect(tokens.size).to eq(expected_count)
      end
    end

    shared_context 'a NucsGl066 record' do
      it 'creates a new record' do
        expect(record).to be_a NucsGl066
        expect(record).to_not be_new_record
      end
    end

    context 'a line with 6 fields' do
      let(:tokens) { NucsGl066.tokenize_source_line '2010|171|4011100|10002342|-|-||' }
      let(:record) { NucsGl066.create_from_source(tokens) }

      it_behaves_like 'tokens', 6
      it_behaves_like 'a NucsGl066 record'
    end

    context 'a line with 8 fields' do
      let(:tokens) { NucsGl066.tokenize_source_line '-|610|4011400|60023761|01|77000|27-APR-09|26-APR-11' }
      let(:record) { NucsGl066.create_from_source(tokens) }

      it_behaves_like 'tokens', 8
      it_behaves_like 'a NucsGl066 record'

      it 'interprets dates with 2 digit years as 21st century dates' do
        expect(record.starts_at).to eq Time.zone.parse('2009-04-27').beginning_of_day
        expect(record.expires_at).to eq Time.zone.parse('2011-04-26').end_of_day
      end
    end

    it 'should give next year as current fiscal year' do
      fiscal_year_test '-|820|1800100|80021533|-|70000||', '2011-10-01', 2012
    end


    it 'should give this year as current fiscal year' do
      fiscal_year_test '-|812|1800100|80021533|-|70000||', '2011-08-01', 2011
    end


    it 'should give this year as current fiscal year when it is fiscal end date' do
      fiscal_year_test '-|812|1800100|80021533|-|70000||', '2011-09-01', 2011
    end


    def fiscal_year_test(chart_string, date, expected_year)
      Timecop.freeze Time.zone.parse(date)

      assert_nothing_raised do
        tokens=NucsGl066.tokenize_source_line chart_string
        expect(tokens.first).to eq(expected_year)
      end
    end

  end

end
