require 'spec_helper'

describe JxmlHoliday do

  it { should validate_presence_of :date }


  describe 'determining if today is a journal holiday' do

    it 'should consider weekends a holiday' do
      (16..17).each do |i|
        Date.stub(:today).and_return Date.parse("2013-02-#{i}")
        JxmlHoliday.today?.should be_true
      end
    end

    it 'should not consider weekdays a holiday' do
      (11..15).each do |i|
        Date.stub(:today).and_return Date.parse("2013-02-#{i}")
        JxmlHoliday.today?.should be_false
      end
    end

    it 'should consider saved dates as holidays' do
      today = Date.parse("2013-02-14")
      JxmlHoliday.create! :date => today
      Date.stub(:today).and_return today
      JxmlHoliday.today?.should be_true
    end

  end


  describe 'determining if a given date is a journal holiday' do

    it 'should consider weekends a holiday' do
      JxmlHoliday.is?(Date.parse("2013-02-16")).should be_true
    end

    it 'should not consider weekdays a holiday' do
      (11..15).each do |i|
        Date.stub(:today).and_return Date.parse("2013-02-#{i}")
        JxmlHoliday.today?.should be_false
      end
    end

    it 'should consider saved dates as holidays' do
      today = Date.parse("2013-02-14")
      JxmlHoliday.create! :date => today
      Date.stub(:today).and_return today
      JxmlHoliday.today?.should be_true
    end

  end


  describe 'importing dates from a file' do

    let(:file_path) { File.expand_path '../support/holidays.txt', File.dirname(__FILE__) }

    it 'should parse all dates and add them to the DB' do
      JxmlHoliday.count.should == 0
      JxmlHoliday.import file_path
      JxmlHoliday.count.should == File.new(file_path).readlines.size
    end

  end

end
