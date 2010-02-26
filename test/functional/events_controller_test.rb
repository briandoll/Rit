require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  should_require_user_access_on('GET #index') { get :index }
  should_require_user_access_on('GET #show') { get :show, :id => Factory(:plate).id }
  should_require_user_access_on('GET #show_row') { get :show_row, :id => Factory(:plate).id }
  should_require_user_access_on('POST #create') { post :create }
  should_require_user_access_on('PUT #update') { put :update, :id => Factory(:plate).id }
  should_require_user_access_on('GET #edit') { get :edit, :id => Factory(:plate).id }
  should_require_user_access_on('DELETE #destroy') { delete :destroy, :id => Factory(:plate).id }

  context 'A user' do
    setup do
      @plate = Factory(:plate)
      @edition_1 = Factory(:published_plate_edition, :plate => @plate)
      @edition_2 = Factory(:future_published_plate_edition, :plate => @plate)
      @event = Factory(:event)
      @user = Factory(:user)
      sign_in_as(@user)
    end

    context 'on GET to #index' do
      setup { get :index }

      should_assign_to :events
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end

    context 'on GET to #show' do
      setup { get :show, :id => @event.id }

      should_assign_to :event
      should_respond_with :success
      should_render_template :show
      should_not_set_the_flash
    end

    context 'on GET to #show_row' do
      setup { get :show_row, :id => @event.id }
      should_render_template 'events/_event.html.erb'
    end

    context 'on POST to :create with valid attributes' do
      setup do
        attributes = Factory.attributes_for(:event)
        attributes = params_from_attributes(attributes)
        xhr :post, :create, :event => { 'new' => attributes }
      end

      should_assign_to :event
      should_redirect_to("the event show") { event_url(assigns(:event)) }
    end

    context 'on XHR GET to :edit' do
      setup { xhr :get, :edit, :id => @event }

      should_assign_to :event
      should_respond_with :success
      should_render_template "events/edit.js.rjs"
    end

    context 'on XHR PUT to :update' do
      setup do
        @attributes = { :name => 'new name',
                        :start_time => 1.month.from_now.change(:hour => 12, :min => 0, :sec => 0),
                        :end_time => 2.months.from_now.change(:hour => 12, :min => 0, :sec => 0) }
        xhr :put, :update, :id => @event.id, :event => { "#{@event.id}" =>  params_from_attributes(@attributes) }
        @updated_event = assigns(:event)
      end

      should_assign_to :event
      should("update the name") { assert_equal(@attributes[:name], @updated_event.name) }
      should("update the start_time") { assert_equal(@attributes[:start_time], @updated_event.start_time) }
      should("update the end_time") { assert_equal(@attributes[:end_time], @updated_event.end_time) }
      should_respond_with :success
      should_render_template "events/update.js.rjs"
    end
  end

end
