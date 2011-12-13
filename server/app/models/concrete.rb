class Concrete < ActiveRecord::Base
  validates :parkingplane_id, :x, :y, :category, :presence => true
  validates :x, :y, :parkingplane_id, :numericality => true

  belongs_to :parkingplane
  
  attr_protected :parkinplane_id
  
  
  @@categories = %w{ street entry exit }
  def self.categories
    @@categories
  end
end
