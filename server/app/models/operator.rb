class Operator < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable
         #, :lockable, :confirmable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  validates :name, :presence => true
  has_many :parkingramps, :dependent => :destroy
  after_create :after_create_cb
  
private
  def after_create_cb
    self.reset_authentication_token!
  end
end
