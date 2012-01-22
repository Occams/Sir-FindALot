class Parkingplane < ActiveRecord::Base
  validates :name, :parkingramp_id, :presence => true
  validates :parkingramp_id, :numericality => true

  belongs_to :parkingramp
  has_many :stats, :dependent => :delete_all, :extend => [StatFindExtension]
  
  # Lots relations
  has_many :lots, :class_name => 'Parkinglot', :dependent => :delete_all
  has_many :concretes, :class_name => 'Concrete', :dependent => :delete_all
  has_many :entries, :class_name => 'Concrete', :conditions => {:category => "entry"}
  has_many :exits, :class_name => 'Concrete', :conditions => {:category => "exit"}
  has_many :taken_lots, :class_name => 'Parkinglot',
           :conditions => {:taken => true}
  has_many :free_lots, :class_name => 'Parkinglot',
           :conditions => {:taken => false}
  
  attr_protected :parkingramp_id
  default_scope :order => 'sorting ASC'
  
  # Save a statistic for this plane
  def stat_down!
    stat = Stat.new
    stat.parkingplane_id = self.id
    stat.lots_total = self.lots_total
    stat.lots_taken = self.lots_taken
    stat.save
  end
  
  def best_lots
    scores = {}
    es = self.exits
    
    # Manhattan distance as ranking algorithm
    self.free_lots.each do |lot|
      scores[lot] = 0
      es.each do |e|
        scores[lot] += (e.x - lot.x).abs + (e.y - lot.y).abs
      end
    end
    scores.sort{|a,b| a[1] <=> b[1]}[0,5].collect{|a| a.first}
  end
  
  # sorts the given planes according in the given order
  def self.sort_down(planes)
    planes.each_with_index do |plane,i|
      plane.update_attribute(:sorting, i)
      plane.save
    end
  end
end
