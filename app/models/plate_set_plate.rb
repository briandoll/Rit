class PlateSetPlate < ActiveRecord::Base
  belongs_to :plate_set
  
  validates_presence_of :plate_name
end
