class Parkingramp < ActiveRecord::Base
  validates :name, :info_pricing, :info_openinghours, :info_address, :presence => true
  validates :latitude, :longitude, :numericality => true
  
  belongs_to :operator
  has_many :parkingplanes, :dependent => :destroy, :order => "sorting ASC"
  has_many :stats, :through => :parkingplanes, :extend => [StatFindExtension]
  
  attr_protected :operator_id
  
  def stat_down!
    self.parkingplanes.map(&:stat_down!)
  end
  
  def reset_cache_values
    total = 0
    taken = 0
    self.parkingplanes.each do |plane|
      plane.update_attribute(:lots_taken, plane.taken_lots.count)
      plane.update_attribute(:lots_total, plane.lots.count)
      total += plane.lots_total
      taken += plane.lots_taken
    end
    self.update_attribute(:lots_taken, taken)
    self.update_attribute(:lots_total, total)
  end
  
  def self.stat_down
    Parkingramp.all.each do |ramp|
      ramp.stat_down!
    end
  end
end
