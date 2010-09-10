ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'fast_context'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase

  private

  # The forms don't take start_time or end_time. Instead, they take start_date and start_hour
  # so we convert the start_time to those fields and remove the *_time parameter.
  def params_from_attributes(attributes)
    params = attributes.stringify_keys
    ['start', 'end'].each do |prefix|
      if params.key? "#{prefix}_time"
        params["#{prefix}_date"] = params["#{prefix}_time"].to_date.strftime(Rit::Config.date_format)
        params["#{prefix}_hour"] = params["#{prefix}_time"].hour.to_s
        params.delete("#{prefix}_time")
      else
        params["#{prefix}_date"] = ''
        params["#{prefix}_hour"] = ''
      end
    end
    params
  end
end