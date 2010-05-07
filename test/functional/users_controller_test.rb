require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  fast_context "An admin user" do
    setup do
      @admin = Factory(:admin_user)
      sign_in_as(@admin)
    end
    
    fast_context 'on GET to #index' do
      setup { get :index }
      
      should_assign_to :users
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end
    
    fast_context 'on POST to #create with valid attributes' do
      setup do
        attributes = Factory.attributes_for(:user)
        post :create, :user => attributes
        @user = assigns(:user)
      end
      
      should_assign_to :user
      should_change("the user count", :by => 1) { User.count }
      should_send_the_confirmation_email_to("the new user") { assigns(:user).email }
      should_set_the_flash_to(/confirming/i)
      should_redirect_to("the users index") { users_url }
    end
    
    fast_context 'on GET to #show' do
      setup do
        @user = Factory(:email_confirmed_user)
        get :show, { :id => @user.id }
      end
      
      should_assign_to :user
      should_render_template :show
      should "set user attributes" do
        assert_equal(@user.email, assigns(:user).email)
        assert_equal(@user.admin, assigns(:user).admin)
      end
    end
    
    fast_context 'on PUT to #update with invalid attributes' do
      setup do
        @user = Factory(:email_confirmed_user)
        @attributes = { 'email' => @user.email, 
                        'password' => 'pass', 
                        'password_confirmation' => 'password2' }
        put :update, { :id => @user.id, :user => @attributes }
      end
      
      should_render_template :show
      should 'not update the password' do
        assert(User.authenticate(@user.email, @attributes['password']).nil?)
        assert(User.authenticate(@user.email, @attributes['password_confirmation']).nil?)
        assert_not_nil(User.authenticate(@user.email, 'password'))
      end
    end
    
    fast_context 'on PUT to #update with valid attributes, same email' do
      setup do
        @user = Factory(:email_confirmed_user)
        @attributes = { 'email' => @user.email,
                        'password' => 'password2',
                        'password_confirmation' => 'password2',
                        'admin' => '1' }
        put :update, { :id => @user.id, :user => @attributes }
      end
      
      should_assign_to :user
      
      # update data
      should("update admin setting") { assert_equal(true, assigns(:user).admin) }
      should "udpate the password" do
        assert(User.authenticate(@user.email, 'password').nil?)
        assert_not_nil(User.authenticate(@user.email, @attributes['password']))
      end
      
      should_set_the_flash_to(/User updated/i)
      should_redirect_to("the users index") { users_url }
    end
    
    fast_context 'on PUT to #update with different email' do
      setup do
        @user = Factory(:email_confirmed_user)
        new_email = @user.email.split('@')
        new_email[0] = new_email[0] << '_new'
        new_email = new_email.join('@')
        @attributes = { 'email' => new_email }
        put :update, { :id => @user.id, :user => @attributes }
      end
      
      should_assign_to :user
      
      # Since the email changed, we will reconfirm the email address
      should_send_the_confirmation_email_to("the new email address") { @attributes['email'] }
      should "set the confirmation flag to false" do
        assert_equal(false, assigns(:user).email_confirmed)
      end
      
      should_send_the_confirmation_email_to("the updated user") { assigns(:user).email }
      should_redirect_to('the users index') { users_url }
    end
    
    # context 'on DELETE to #destroy with a valid user' do
    #   setup do
    #     @user = Factory(:email_confirmed_user)
    #     delete :destroy, { :id => @user.id }
    #   end
    #   
    #   should_assign_to :user
    #   should "set the active flag to false" do
    #     assert_equal(false, assigns(:user).active)
    #   end
    #   should_set_the_flash_to(/suspended/i)
    #   should_redirect_to('the user index') { user_url } 
    # end
  end
      
  should_require_admin_access_on('GET #index') { get :index }
  should_require_admin_access_on('POST #create') { post :create }
  should_require_admin_access_on('GET #new') { get :new }
  should_require_admin_access_on('GET #show') { get :show, { :id => Factory(:user).id } }
  should_require_admin_access_on('PUT #update') { put :update, { :id => Factory(:user).id } }
  # should_require_admin_access_on('DELETE #destroy') { delete :destroy, { :id => @user.id } }
end
