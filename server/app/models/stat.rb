class Stat < ActiveRecord::Base
  belongs_to :parkingplane
  
  before_create :set_dates
  
  def set_dates
    d = self.created_at || DateTime.current
    self.created_at_year = d.year
    self.created_at_month = d.month
    self.created_at_day = d.day
    self.created_at_hour = d.hour
  end
  
  # TODO: Pack old stats
  def self.pack!
  end
end
