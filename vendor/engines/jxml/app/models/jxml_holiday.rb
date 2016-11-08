class JxmlHoliday < ActiveRecord::Base

  include ActiveModel::ForbiddenAttributesProtection

  validates_presence_of :date

  scope :current_and_upcoming, -> { where('"JXML_HOLIDAYS"."DATE" >= ?', Time.current.to_date) }

  def self.is?(date)
    day_of_week = date.cwday
    return true if day_of_week > 5
    where(date: date..date.end_of_day).present?
  end

  def self.today?
    is? Date.today
  end

  def self.import(file_path)
    File.new(file_path).readlines.each do |date|
      create! date: Date.parse(date.strip)
    end
  end

end
