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

require 'test_helper'

class PlateSetTest < ActiveSupport::TestCase
  should_have_many :plate_set_plates
  
  should_validate_presence_of :name, :layout_name
end
