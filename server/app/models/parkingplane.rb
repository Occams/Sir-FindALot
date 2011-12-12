class Parkingplane < ActiveRecord::Base
  validates :name, :parkingramp_id, :presence => true
  validates :parkingramp_id, :numericality => true

  belongs_to :parkingramp
  has_many :stats, :dependent => :delete_all
  
  # Lots relations
  has_many :lots, :class_name => 'Parkinglot', :dependent => :delete_all
  has_many :concretes, :dependent => :delete_all
  
  attr_protected :parkingramp_id
  
  def update_lots_count
    self.lots_total = self.lots.count
  end
end
