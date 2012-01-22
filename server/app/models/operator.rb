class Operator < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  validates :name, :presence => true
  has_many :parkingramps, :dependent => :destroy
  after_create :after_create_cb
  
private
  def after_create_cb
    self.reset_authentication_token!
  end
end
