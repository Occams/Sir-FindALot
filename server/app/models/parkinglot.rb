class Parkinglot < ActiveRecord::Base
  @@categories = %w{ normal disabled women }
  def self.categories
    @@categories
  end
  
  

  # Validations
  validates_inclusion_of :category, :in => @@categories
  validates :parkingplane_id, :x, :y, :category, :presence => true
  validates :x, :y, :parkingplane_id, :numericality => true
  attr_protected :parkinplane_id
  
  # Callbacks
  after_initialize :default_values
  after_create :create_callback
  after_destroy :destroy_callback
  after_update :update_callback

  # Relations
  belongs_to :parkingplane
  
private
  def default_values
    self.category ||= @@categories.first.to_s
  end
  
  def create_callback
    inc_total_values
  end
  
  def destroy_callback
    dec_total_values
    if self.taken
      dec_taken_values
    end
  end
  
  def update_callback
    if self.taken_changed?
      if self.taken
        inc_taken_values
      else
        dec_taken_values
      end
    end
  end
  
  def inc_total_values
    self.parkingplane.lots_total += 1
    self.parkingplane.parkingramp.lots_total +=1
  end
  
  def dec_total_values
    self.parkingplane.lots_total -= 1
    self.parkingplane.parkingramp.lots_total -=1
  end
  
  def inc_taken_values
    self.parkingplane.lots_taken -= 1
    self.parkingplane.parkingramp.lots_taken -= 1
  end
  
  def dec_taken_values
    self.parkingplane.lots_taken -= 1
    self.parkingplane.parkingramp.lots_taken -= 1
  end
end
