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
  
  # Reset the cache values of this record and its attached parkingplanes.
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
  
  # Calculates the best parkinplane and returns it's id.
  def best_level
    # Best level means that it has relatively the most free lots.
    level = self.parkingplanes.collect do |p|
      { :id => p.id, :score => (p.lots_taken.nil? || p.lots_total.nil? || p.lots_total == 0) ? 0 : 1 - p.lots_taken / p.lots_total.to_f }
    end
    
    level = level.sort{|a,b| a[:score] <=> b[:score]}.delete_if{|e| e[:score] == 0 }
    
    if level.empty? then nil else level.last[:id] end
  end
  
  def self.stat_down
    Parkingramp.all.each do |ramp|
      ramp.stat_down!
    end
  end

  # Rank parkingramps by the given geolocation, a search string and the 
  # previous vistited parkingramps. The geolocation needs to be structured
  # like geolocation[:coords] = { :latitude => ... , :longitude => ... }
  # The needle is just a simple string
  # The history is expected to be an array containing hashes with {:id => rampid, :date => unixtimestamp }
  def self.rankby(geolocation, needle, history)
  
    # We store the different sql queries in the parts array. Later we join them via UNION and sum up the scores.
    parts = []
  
    # Geolocation part
    if !geolocation.nil? && geolocation[:coords] && geolocation[:coords][:latitude] && geolocation[:coords][:longitude]
      geosql = Parkingramp.near([geolocation[:coords][:latitude], geolocation[:coords][:longitude]], 20).to_sql.gsub(/ORDER .*$/, "")
      parts.push "SELECT parkingramps.*, 1-geo.distance/40 as score FROM parkingramps, (#{geosql}) as geo WHERE geo.id = parkingramps.id"
    end

    # Text search
    if !needle.nil? && !needle.strip.empty?
      parts.push Parkingramp.where("LOWER(name) LIKE ?", "%#{needle.strip.downcase}%").select("parkingramps.*, 1 as score").to_sql
    end
    
    # History
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
      Parkingramp.find_by_sql "SELECT p.* FROM (#{parts.join(" UNION ALL ")}) as p WHERE p.lots_total > 0 GROUP BY p.id ORDER BY SUM(p.score) DESC"
    end
    
  end
  
private
  # We propse an simple continous algorithm for ranking parkingramps. 
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
