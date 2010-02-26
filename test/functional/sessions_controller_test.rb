require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  context 'on POST to #create with inactive user' do
    setup do
      @user = Factory(:inactive_user)
      post :create, :session => { :email    => @user.email,
                                  :password => @user.password }
    end
    
    should_deny_access(:flash => /deactivated/i)
  end
end
