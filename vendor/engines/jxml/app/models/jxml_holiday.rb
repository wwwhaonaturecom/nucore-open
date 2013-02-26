class JxmlHoliday < ActiveRecord::Base

  validates_presence_of :date


  def self.is?(date)
    day_of_week = date.cwday
    day_of_week == 6 || day_of_week == 7 || find_by_date(date.to_time).present?
  end


  def self.today?
    is? Date.today
  end


  def self.import(file_path)
    File.new(file_path).readlines.each do |date|
      create! :date => Date.parse(date.strip)
    end
  end

end
