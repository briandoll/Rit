require 'active_support'

module Rit
  module Config
    mattr_accessor :date_format
    @@date_format = "%m/%d/%Y"
  end
end
