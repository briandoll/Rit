require 'test_helper'

class PlatesControllerTest < ActionController::TestCase
  # TODO - Remove RESTful routes?  Not supporting xml anyway...

  # because route order matters
  should_route :post, "/plates", :controller => :plates, :action => :create
  should_route :post, "/plates/1", :controller => :plates, :action => :create_plate_edition, :id => '1'

  should_require_user_access_on('GET #index') { get :index }
  should_require_user_access_on('GET #show') { get :show, :id => Factory(:plate).id }
  should_require_user_access_on('GET #show_row') { get :show_row, :id => Factory(:plate).id }
  should_require_admin_access_on('POST #create') { post :create }
  should_require_user_access_on('POST #create_plate_edition') { post :create_plate_edition, :id => Factory(:plate).id }
  should_require_admin_access_on('GET #new') { get :new }
  should_require_admin_access_on('PUT #update') { put :update, :id => Factory(:plate).id }
  should_require_admin_access_on('GET #edit') { get :edit, :id => Factory(:plate).id }
  should_require_admin_access_on('DELETE #destroy') { delete :destroy, :id => Factory(:plate).id }

  context "An admin user" do
    setup do
      @user = Factory(:admin_user)
      sign_in_as(@user)
    end

    context 'on GET to #new' do
      setup { get :new }

      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
    end

    context 'on POST to #create with valid attributes' do
      setup do
        attributes = Factory.attributes_for(:plate)
        post :create, :plate => { 'new' => attributes }
      end

      should_assign_to :plate
      should_change("the plate count", :by => 1) { Plate.count }
      should_set_the_flash_to(/created/i)
      should_redirect_to("the plates index") { plates_path }
    end

    context 'on GET to #edit' do
      setup do
        @plate = Factory(:plate)
        get :edit, { :id => @plate.id }
      end

      should_assign_to :plate
      should_respond_with :success
      should_render_template :edit
    end

    context 'on PUT to #update with valid attributes' do
      setup do
        @plate = Factory(:plate)
        # TODO - How much can an admin update versus a user?
        @attributes = { 'layout_name'   => 'updated_layout',
                        'plate_name'    => 'updated_plate',
                        'instance_name' => 'updated_instance' }
        put :update, { :id    => @plate.id,
                       :plate => { @plate.id.to_s => @attributes }}
        @plate = assigns(:plate)
      end

      should_assign_to(:plate)
      should("update the layout name") { assert_equal(@attributes['layout_name'], @plate.layout_name) }
      should("update the plate name") { assert_equal(@attributes['plate_name'], @plate.plate_name) }
      should("update the instance name") { assert_equal(@attributes['instance_name'], @plate.instance_name) }
      should_set_the_flash_to(/Plate was successfully updated/i)
      should_redirect_to('the plate index') { plate_url(@plate) }
    end

    context 'on DELETE to #destroy with a valid id' do
      setup do
        @plate = Factory(:plate)
        delete :destroy, :id => @plate.id
      end

      # we added a new plate and deleted it in the setup
      should_not_change("the plate count") { Plate.count }
      should_set_the_flash_to(/deleted/i)
      should_redirect_to('the plate index') { plates_url }
    end

    context 'on XHR GET to :show_row' do
      setup { xhr :get, :show_row, :id => Factory(:plate).id }
      should_render_template :plate
    end

    context 'on XHR GET to :edit' do
      setup do
        @plate = Factory(:plate)
        xhr :get, :edit, { :id => @plate.id }
      end

      should_assign_to :plate
      should_respond_with :success
      should_render_template 'plates/edit.js.rjs'
      should "replace plate-row div" do
      end
    end

    context 'on XHR POST to :update' do
      setup do
        @plate = Factory(:plate)
        # TODO - How much can an admin update versus a user?
        @attributes = { 'layout_name'   => 'updated_layout',
                        'plate_name'    => 'updated_plate',
                        'instance_name' => 'updated_instance' }
        xhr :put, :update, { :id    => @plate.id,
                            :plate => { @plate.id.to_s => @attributes }}
        @plate = assigns(:plate)
      end

      should_assign_to(:plate)
      should("update the layout name") { assert_equal(@attributes['layout_name'], @plate.layout_name) }
      should("update the plate name") { assert_equal(@attributes['plate_name'], @plate.plate_name) }
      should("update the instance name") { assert_equal(@attributes['instance_name'], @plate.instance_name) }
      should_render_template 'plates/update.js.erb'
    end

    context 'on POST to :create_plate_edition with valid attributes' do
      setup do
        @plate = Factory(:plate)
        attributes = Factory.attributes_for(:published_plate_edition, :plate => @plate)
        attributes = params_from_attributes(attributes)
        post :create_plate_edition, { :id => @plate.id, :plate_edition => { 'new_plate_edition' => attributes } }
      end

      should_assign_to :plate_edition
      should_redirect_to("the plate show") { plate_url(@plate) }
    end
  end

  context 'A user' do
    setup do
      @user = Factory(:email_confirmed_user)
      sign_in_as(@user)
    end

    context 'on GET to #index' do
      setup { get :index }

      should_assign_to :plates
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end

    context 'on GET to #index' do
      setup do
        Factory(:plate, :layout_name => 'foo', :instance_name => '', :plate_name => 'box-1')
        Factory(:plate, :layout_name => 'foo', :instance_name => '', :plate_name => 'box-2')
      end

      context 'with layout filter' do
        setup { get :index, :fl => 'foo' }

        should_assign_to :plates
        should "list 2 plates" do
          assert_equal(2, assigns(:plates).size)
        end
        should_respond_with :success
        should_render_template :index

        should "set the page title to 'foo::'" do
          assert_select 'title', /foo::/
        end
      end

      context "with full filters" do
        setup { get :index, :fl => 'foo', :fi => '', :fp => 'box-1'}

        should_assign_to :plates
        should "list 1 plate" do
          assert_equal(1, assigns(:plates).size)
        end
        should_respond_with :success
        should_render_template :index
        should "set the page title to 'foo::box-1'" do
          assert_select 'title', /foo::box-1/
        end
      end
    end

    context 'on GET to #show' do
      setup do
        @plate = Factory(:plate)
        get :show, :id => @plate.id
      end

      should_assign_to :plate
      should_respond_with :success
      should_render_template :show
      should_not_set_the_flash
    end
  end


  #
  # PUBLISHING
  #

  context "a Plate with no editions" do
    setup do
      @plate = Factory(:plate)
      get_published_plate(@plate)
    end

    should "return nothing when sent :publish" do
      assert_nil(assigns(:edition))
      assert_equal('', @response.body)
    end
  end

  context "with a singleton Plate and many PlateEditions" do
    setup do
      @plate = Factory(:plate)
      @default_edition = Factory(:default_plate_edition, :plate => @plate)
      @current_edition = Factory(:published_plate_edition, :plate => @plate)
      @future_edition = Factory(:future_published_plate_edition, :plate => @plate)
    end

    context "on GET to :show for the plate without a date" do
      setup do
        get_published_plate(@plate)
      end
      should_publish("the current edition") { @current_edition }
    end

    context "on GET to :show for the plate with a future date" do
      setup do
        get_published_plate(@plate, 1.week.from_now + 1.day)
      end
      should_publish("the future edition") { @future_edition }
    end

    context "on GET to :show for the plate with a past date" do
      setup do
        get_published_plate(@plate, 1.day.ago)
      end
      should_publish("the default edition") { @default_edition }
    end

    context "on GET to :publish with an invalid plate" do
      setup do
        @plate = Factory.build(:plate)
        get_published_plate(@plate)
      end
      should_respond_with :missing
    end
  end

  context "with a multi-instance Plate and many PlateEditions" do
    setup do
      @plate = Factory(:plate)
      @default_edition = Factory(:default_plate_edition, :plate => @plate)
      @current_edition = Factory(:published_plate_edition, :plate => @plate)
      @future_edition = Factory(:future_published_plate_edition, :plate => @plate)
    end

    context "on GET to :show for the plate without a date" do
      setup do
        get_published_plate(@plate)
      end
      should_publish("the current edition") { @current_edition }
    end

    context "on GET to :show for the plate with a future date" do
      setup do
        get_published_plate(@plate, 1.week.from_now + 1.day)
      end
      should_publish("the future edition") { @future_edition }
    end

    context "on GET to :show for the plate with a past date" do
      setup do
        get_published_plate(@plate, 1.day.ago)
      end
      should_publish("the default edition") { @default_edition }
    end
  end

  private

  def get_published_plate(plate, date=nil)
    args = { :layout_name  => plate.layout_name,
             :instance_name => (plate.instance_name or ''),
             :plate_name   => plate.plate_name }
    args[:date] = date.to_i unless date.nil?
    get(:published, args)
  end

end
