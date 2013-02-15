class JxmlHoliday < ActiveRecord::Base

  validates_presence_of :date


  def self.today?
    today = Date.today
    day_of_week = today.cwday
    day_of_week == 6 || day_of_week == 7 || find_by_date(today.to_time).present?
  end


  def self.import(file_path)
    File.new(file_path).readlines.each do |date|
      create! :date => Date.parse(date.strip)
    end
  end

end
