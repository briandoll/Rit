require 'test_helper'

class PlateSetPlatesControllerTest < ActionController::TestCase
  should_require_user_access_on('GET #index') { get :index, :plate_set_id => Factory(:plate_set).id }
  should_require_user_access_on('GET #show') { get :show, :id => Factory(:plate_set_plate).id }
  should_require_admin_access_on('GET #edit') { get :edit, :id => Factory(:plate_set_plate).id }
  should_require_admin_access_on('PUT #update') { put :update, :id => Factory(:plate_set_plate).id }
  should_require_admin_access_on('DELETE #destroy') { delete :destroy, :id => Factory(:plate_set_plate).id }

  context "A user" do
    setup do
      @plate_set = Factory(:plate_set)
      @plate_1 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @plate_2 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @user = Factory(:user)
      sign_in_as(@user)
    end

    fast_context "on XHR GET to :index" do
      setup { xhr :get, :index, :plate_set_id => @plate_set }

      should_assign_to :plate_set
      should_assign_to :plate_set_plates
      should_respond_with :success
      should_render_template :_plate_set_plates
    end

    fast_context 'on XHR GET to :show' do
      setup do
        xhr :get, :show, :id => @plate_1.id
      end

      should_assign_to :plate_set_plate
      should_respond_with :success
      should_render_template :_plate_set_plate
    end
  end

  context "An admin user" do
    setup do
      @plate_set = Factory(:plate_set)
      @plate_1 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @plate_2 = Factory(:plate_set_plate, :plate_set => @plate_set)
      @admin_user = Factory(:admin_user)
      sign_in_as(@admin_user)
    end

    fast_context 'on XHR GET to :edit' do
      setup { xhr :get, :edit, :id => @plate_1 }

      should_assign_to :plate_set_plate
      should_respond_with :success
      should_render_template "plate_set_plates/edit.js.rjs"
    end

    fast_context 'on XHR PUT to :update' do
      setup do
        @attributes = { :plate_name        => 'new name',
                        :description => 'new description' }
        xhr(:put, :update, :id => @plate_1.id, :plate_set_plate => { "#{@plate_1.id}" => @attributes })
        @updated_plate = assigns(:plate_set_plate)
      end

      should_assign_to :plate_set_plate
      should("update the name") { assert_equal(@attributes[:plate_name], @updated_plate.plate_name) }
      should("update the description") { assert_equal(@attributes[:description], @updated_plate.description) }
      should_respond_with :success
      should_render_template "plate_set_plates/update.js.rjs"
    end

    context 'on XHR DELETE to :destroy' do
      # TODO - this
    end
  end

end
