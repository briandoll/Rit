# Load the rails application
require File.expand_path('../application', __FILE__)

# TODO RAILS3 - copied from environment.rb.rails2 maybe more into initializers?
# require File.join(Rails.root, '/config/rit_config')

# Initialize the rails application
Rit::Application.initialize!
