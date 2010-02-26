require 'test_helper'

class PlateSetTest < ActiveSupport::TestCase
  should_have_many :plate_set_plates
  
  should_validate_presence_of :name, :layout_name
end
