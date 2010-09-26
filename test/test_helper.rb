ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'fast_context'

require 'minitest/unit'
MiniTest::Unit.autorun

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase

  private

  # The forms don't take start_time or end_time.  Instead, they take start_date and start_hour
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
