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
  
    if !geolocation.nil? && geolocation[:coords] && geolocation[:coords][:latitude] && geolocation[:coords][:longitude]
      geosql = Parkingramp.near([geolocation[:coords][:latitude], geolocation[:coords][:longitude]]).to_sql.gsub(/ORDER .*$/, "")
      parts.push "SELECT parkingramps.*, 10 as score FROM parkingramps, (#{geosql}) as geo WHERE geo.id = parkingramps.id"
    end

    if !needle.nil?
      parts.push Parkingramp.where("LOWER(name) LIKE ?", "%#{needle.downcase}%").select("parkingramps.*, 5 as score").to_sql
    end
    
    if !history.nil? && history.respond_to?(:each)
      # Collect all ramps that were visited at the same weekday near the current
      # time and map a score value to them
      
      # Acceptable difference of time in seconds
      d_m = 35*60
      # Acceptable difference of weekdays in days
      d_w = 1
      
      history.each do |entry|
        if entry[:id] && entry[:date]
          date = Time.at entry[:date]
          c_date = Time.now
          
          t0_secs = date.hour.hours + date.min.minutes + date.sec.seconds
          t1_secs = c_date.hour.hours + c_date.min.minutes + c_date.sec.seconds

          wday_diff = [(date.wday - Time.current.wday).abs, 7 - (date.wday - Time.current.wday).abs].min / d_w.to_f
          hour_diff = [(t0_secs - t1_secs).abs, 86400.seconds - (t0_secs - t1_secs).abs].min / d_m.to_f
          
          parts.push Parkingramp.where("id = ?", entry[:id].to_i).select("parkingramps.*, 10 as score").to_sql
        end
      end
    end
    
    if parts.empty?
      []
    else
      puts "SELECT p.* FROM (#{parts.map{|p| "#{p}"}.join(" UNION ALL ")}) as p GROUP BY p.id ORDER BY SUM(p.score) DESC"
      Parkingramp.find_by_sql "SELECT p.* FROM (#{parts.join(" UNION ALL ")}) as p GROUP BY p.id ORDER BY SUM(p.score) DESC"
    end
    
  end
end
