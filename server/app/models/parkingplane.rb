class Parkingplane < ActiveRecord::Base
  validates :name, :parkingramp_id, :presence => true
  validates :parkingramp_id, :numericality => true

  belongs_to :parkingramp
  has_many :stats, :dependent => :delete_all
  
  # Lots relations
  has_many :lots, :class_name => 'Parkinglot', :dependent => :delete_all
  has_many :concretes, :class_name => 'Concrete', :dependent => :delete_all
  has_many :taken_lots, :class_name => 'Parkinglot',
           :conditions => {:taken => true}
  
  attr_protected :parkingramp_id
  
  # Save a statistic for this plane
  def stat_down!
    stat = Stat.new
    stat.parkingplane_id = self.id
    stat.lots_total = self.lots_total
    stat.lots_taken = self.lots_taken
    stat.save
  end
  
  # overwrite lots_taken and lots_total field, TODO cache this values
  def lots_taken
    self.taken_lots.count
  end
  
  def lots_total
    self.lots.count
  end
end
