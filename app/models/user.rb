class User < ActiveRecord::Base
  include Clearance::User
  
  attr_accessible :admin, :active
  
  def admin?
    admin
  end
  
  def active?
    active
  end
end
