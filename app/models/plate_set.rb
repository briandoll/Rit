# == Schema Information
#
# Table name: plate_sets
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  layout_name :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class PlateSet < ActiveRecord::Base
  has_many :plate_set_plates

  validates_presence_of :name, :layout_name

  def create_plates(instance_name, description)
    # TODO - handle errors
    plate_set_plates.each do |plate_name|
      plate = Plate.new(:layout_name => layout_name, :instance_name => instance_name, :plate_name => plate_name)
      plate.save
    end
  end
end
