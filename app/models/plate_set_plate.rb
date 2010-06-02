# == Schema Information
#
# Table name: plate_set_plates
#
#  id           :integer         not null, primary key
#  plate_set_id :integer
#  plate_name   :string(255)
#  description  :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class PlateSetPlate < ActiveRecord::Base
  belongs_to :plate_set
  
  validates_presence_of :plate_name
end
