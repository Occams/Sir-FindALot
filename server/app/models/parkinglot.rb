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

  # Relations
  belongs_to :parkingplane
  
private
  def default_values
    self.category ||= @@categories.first.to_s
  end
end
