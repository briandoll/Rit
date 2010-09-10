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

require File.join(File.dirname(__FILE__), '..', 'test_helper')

class PlateSetTest < ActiveSupport::TestCase
  should have_many :plate_set_plates
  
  should validate_presence_of :name
  should validate_presence_of :layout_name
end
