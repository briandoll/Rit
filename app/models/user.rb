# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  email              :string(255)
#  encrypted_password :string(128)
#  salt               :string(128)
#  confirmation_token :string(128)
#  remember_token     :string(128)
#  email_confirmed    :boolean         default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  admin              :boolean         default(FALSE)
#  active             :boolean         default(TRUE), not null
#
# Indexes
#
#  index_users_on_remember_token             (remember_token)
#  index_users_on_id_and_confirmation_token  (id,confirmation_token)
#  index_users_on_email                      (email)
#

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
