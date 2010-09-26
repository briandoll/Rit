# http://github.com/jerry/clearance_admins

module Clearance
  module Shoulda

    def should_send_the_confirmation_email_to(description, &block)
      should "send the confirmation email to #{description}" do
        expected_to = instance_eval(&block)
        assert_sent_email do |email|
          email.to.any? { |e| not (e =~ /#{expected_to}/i).nil? } and email.subject =~ /account confirmation/i
        end
      end
    end

    def should_require_admin_access_on(description, &block)
      context " #{description}" do
        setup do
          @user = Factory(:email_confirmed_user)
          sign_in_as(@user)
          instance_eval(&block)
        end
        should_deny_access(:flash => /please login as an administrator/i)
      end
    end

    def should_require_user_access_on(description, &block)
      context " #{description}" do
        setup do
          instance_eval(&block)
        end
        should_deny_access
      end
    end
  end
end

class Test::Unit::TestCase
  include Clearance::Shoulda::Helpers
end
Test::Unit::TestCase.extend(Clearance::Shoulda)
