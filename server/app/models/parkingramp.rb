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
  
  def best_level
    lots = self.parkingplanes.collect{|p| { :id => p.id, :score => 1 - p.lots_taken/p.lots_total.to_f } }
    return lots.sort{|a,b| a[:score] <=> b[:score]}.last[:id]
  end
  
  def self.stat_down
    Parkingramp.all.each do |ramp|
      ramp.stat_down!
    end
  end
  
  def self.rankby(geolocation, needle, history)
    parts = []
  
    if !geolocation.nil? && geolocation[:coords] && geolocation[:coords][:latitude] && geolocation[:coords][:longitude]
      geosql = Parkingramp.near([geolocation[:coords][:latitude], geolocation[:coords][:longitude]], 20).to_sql.gsub(/ORDER .*$/, "")
      parts.push "SELECT parkingramps.*, 1-geo.distance/40 as score FROM parkingramps, (#{geosql}) as geo WHERE geo.id = parkingramps.id"
    end

    if !needle.nil?
      parts.push Parkingramp.where("LOWER(name) LIKE ?", "%#{needle.downcase}%").select("parkingramps.*, 1 as score").to_sql
    end
    
    if !history.nil? && history.respond_to?(:each)
      # Collect all ramps that were visited at the same weekday near the current
      # time and map a score value to them
      
      history.each do |entry|
        if entry[:id] && entry[:date]
          date = Time.at entry[:date]/1000
          c_date = Time.now
          
          t0_secs = date.hour.hours + date.min.minutes + date.sec.seconds
          t1_secs = c_date.hour.hours + c_date.min.minutes + c_date.sec.seconds

          wday_diff = [(date.wday - Time.current.wday).abs, 7 - (date.wday - Time.current.wday).abs].min
          hour_diff = [(t0_secs - t1_secs).abs, 1.day.seconds - (t0_secs - t1_secs).abs].min
          wday_jump = (([0,6].include?(date.wday) && [0,6].include?(c_date.wday)) || (date.wday.between?(1,5) && c_date.wday.between?(1,5))) ? 0 : 1
          
          score = self.score_history hour_diff, wday_diff, wday_jump
          
          parts.push Parkingramp.where("id = ?", entry[:id].to_i).select("parkingramps.*, #{score} as score").to_sql
        end
      end
    end
    
    if parts.empty?
      []
    else
      Parkingramp.find_by_sql "SELECT p.* FROM (#{parts.join(" UNION ALL ")}) as p GROUP BY p.id ORDER BY SUM(p.score) DESC"
    end
    
  end
  
private

=begin
  Alles was hier drin steht zwischen begin und end ist ein kommentar
=end
  def self.score_history(diff_sec, diff_wday, is_weekend_workday_jump, acceptable_diff_sec = 45*60, smooth_first = 2, smooth_second = 3)
    first = (1 - is_weekend_workday_jump*diff_wday/4.0 - diff_wday/12.0)*smooth_first
    second = 1 - 2**(diff_sec/smooth_second - acceptable_diff_sec)
    
    if second <= 0
      return 0
    else
      return first*second
    end
  end
end
