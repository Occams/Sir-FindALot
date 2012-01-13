class Parkingramp < ActiveRecord::Base
  validates :name, :info_pricing, :info_openinghours, :info_address, :presence => true
  validates :latitude, :longitude, :numericality => true
  
  belongs_to :operator
  has_many :parkingplanes, :dependent => :destroy, :order => "sorting ASC"
  has_many :stats, :through => :parkingplanes, :extend => [StatFindExtension]
  
  attr_protected :operator_id
  
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode  # auto-fetch address
  
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
  
  def self.rankby(geolocation, needle, history)
    parts = []
  
    if !geolocation.nil?
      parts.push Parkingramp.near([geolocation[:coords][:latitude], geolocation[:coords][:longitude]]).select("parkingramps.*, 5 as score").to_sql
    end

    if !needle.nil?
      parts.push Parkingramp.where("LOWER(name) LIKE ?", "%#{needle.downcase}%").select("parkingramps.*, 1 as score").to_sql
    end
    
    if !history.nil?
      # Collect all ramps that were visited at the same weekday near the current
      # time and map a score value to them
      #TODO this one
      #parts.push Parkingramp.where("id in (?)", history.collect{|h| h[
    end
    
    if parts.empty?
      []
    else
      Parkingramp.find_by_sql "SELECT p.* FROM (#{parts.join(" UNION ALL ")}) as p GROUP BY p.id ORDER BY SUM(p.score) DESC"
    end
    
  end
end
