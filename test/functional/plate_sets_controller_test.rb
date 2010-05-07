require 'test_helper'

class PlateSetsControllerTest < ActionController::TestCase
  
  should_route :post, '/plate_sets', :controller => :plate_sets, :action => :create
  should_route :post, '/plate_sets/1', :controller => :plate_sets, :action => :create_plate, :id => '1'
  
  should_require_user_access_on('GET #index') { get :index }
  should_require_user_access_on('GET #show') { get :show, :id => Factory(:plate_set).id }
  should_require_user_access_on('GET #show_row') { get :show_row, :id => Factory(:plate_set).id }
  should_require_admin_access_on('POST #create') { post :create }
  should_require_admin_access_on('PUT #update') { put :update, :id => Factory(:plate_set).id }
  should_require_admin_access_on('GET #edit') { get :edit, :id => Factory(:plate_set).id }
  should_require_admin_access_on('DELETE #destroy') { delete :destroy, :id => Factory(:plate_set).id }
  should_require_admin_access_on('POST #create_plate') { post :create_plate, :id => Factory(:plate_set).id }
  should_require_user_access_on('PUT #generate') { put :generate_plates, :id => Factory(:plate_set).id,:instance_name => 'page' }

  context 'A user' do
    setup do
      @plate_set = Factory(:plate_set)
      @plate_1 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @plate_2 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @user = Factory(:user)
      sign_in_as(@user)
    end

    fast_context 'on GET to #index' do
      setup { get :index }

      should_assign_to :plate_sets
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end

    fast_context 'on GET to #show' do
      setup { get :show, :id => @plate_set.id }

      should_assign_to :plate_set
      should_respond_with :success
      should_render_template :show
      should_not_set_the_flash
    end
    
    fast_context 'on GET to #show_row' do
      setup { get :show_row, :id => @plate_set.id }
      should_render_template :plate_set
    end
  end

  context 'An admin user' do
    setup do
      @plate_set = Factory(:plate_set)
      @plate_1 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @plate_2 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @admin_user = Factory(:admin_user)
      sign_in_as(@admin_user)
    end

    fast_context 'on POST to :create with valid attributes' do
      setup do
        attributes = Factory.attributes_for(:plate_set)
        xhr :post, :create, :plate_set => { 'new' => attributes }
      end

      should_assign_to :plate_set
      should_redirect_to("the plate set show action") { plate_set_url(assigns(:plate_set)) }
    end

    fast_context 'on XHR GET to :edit' do
      setup { xhr :get, :edit, :id => @plate_set }

      should_assign_to :plate_set
      should_respond_with :success
      should_render_template "plate_sets/edit.js.rjs"
    end

    fast_context 'on XHR PUT to :update' do
      setup do
        @attributes = { :name => 'new name',
                        :description => 'new desc' }
        xhr :put, :update, :id => @plate_set.id, :plate_set => { "#{@plate_set.id}" => @attributes }
        @updated_plate_set = assigns(:plate_set)
      end

      should_assign_to :plate_set
      should("update the name") { assert_equal(@attributes[:name], @updated_plate_set.name) }
      should("update the description") { assert_equal(@attributes[:description], @updated_plate_set.description) }
      should_respond_with :success
      should_render_template "plate_sets/update.js.rjs"
    end

    fast_context 'on POST to :create_plate with valid attributes' do
      setup do
        attributes = Factory.attributes_for(:plate_set_plate, :plate_set => @plate_set)
        post :create_plate, { :id => @plate_set.id, :plate_set_plate => { 'new_plate_set_plate' => attributes } }
      end

      should_assign_to :plate_set_plate
      should_redirect_to("the plate_set show action") { plate_set_url(@plate_set) }
    end

    fast_context 'on PUT to :generate_plates' do
      setup do
        put :generate_plates, :id => @plate_set.id, :instance_name => 'page'
      end

      should_redirect_to("the plate index page") { plates_url(:fl => @plate_set.layout_name, :fi => 'page') }
      should_change("the plate count", :by => 2) { Plate.count }
      should "create the proper plates" do
        assert_not_nil(Plate.find(:first, :conditions => { :layout_name   => @plate_set.layout_name,
                                                           :instance_name => 'page',
                                                           :plate_name    => @plate_1.plate_name }))
        assert_not_nil(Plate.find(:first, :conditions => { :layout_name   => @plate_set.layout_name,
                                                           :instance_name => 'page',
                                                           :plate_name    => @plate_2.plate_name }))
      end
    end
  end
end
