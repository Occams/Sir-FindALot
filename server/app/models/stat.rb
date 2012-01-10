class Stat < ActiveRecord::Base
  belongs_to :parkingplane
  
  before_create :set_dates
  
  def set_dates
    self.created_at_year = Date.current.year
    self.created_at_month = Date.current.month
    self.created_at_day = Date.current.day
    self.created_at_hour = DateTime.current.hour
  end
  
  # TODO: Pack old stats
  def self.pack!
  end
end
