class HashObject
  @category
  @translation
  
  def initialize(cat, trans)
    @category = cat
    @translation = trans
  end
  
  attr_accessor :category, :translation
end

module Admin::ParkingplanesHelper
  def concrete_categories
    abstract_categories(Concrete)
  end
  
  def parkinglot_categories
    abstract_categories(Parkinglot)
  end
  
  def abstract_categories(collection)
    collection.categories.collect do |c|
      HashObject.new(c, collection.t(c))
    end
  end
end
