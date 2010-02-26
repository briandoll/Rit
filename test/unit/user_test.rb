require File.dirname(__FILE__) + '/../test_helper'
 
class UserTest < ActiveSupport::TestCase  
  should_allow_mass_assignment_of :admin
end