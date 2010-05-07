require 'test_helper'

class PlateEditionsControllerTest < ActionController::TestCase

  should_route :get, "/plate_editions/search", :controller => :plate_editions, :action => :search
  should_route :get, "/plate_editions/1", :controller => :plate_editions, :action => :show, :id => '1'

  should_require_user_access_on('GET #index') { get :index, :plate_id => Factory(:plate).id }
  should_require_user_access_on('GET #new') { get :new, :plate_id => Factory(:plate).id }
  should_require_user_access_on('GET #edit') { get :edit, :id => Factory(:plate_edition).id }
  should_require_user_access_on('GET #show') { get :show, :id => Factory(:plate_edition).id }
  should_require_user_access_on('PUT #update') { put :update, :id => Factory(:plate_edition).id }
  should_require_user_access_on('DELETE #destroy') { delete :destroy, :id => Factory(:plate_edition).id }
  should_require_user_access_on('GET #search') { get :search, :q => 'query' }

  context "A user" do
    setup do
      @plate = Factory(:plate)
      @default_edition = Factory(:default_plate_edition, :plate => @plate)
      @edition_1 = Factory(:published_plate_edition, :plate => @plate)
      @edition_2 = Factory(:future_published_plate_edition, :plate => @plate)
      @user = Factory(:user)
      sign_in_as(@user)
    end

    fast_context "on XHR GET to :index" do
      setup { xhr :get, :index, :plate_id => @plate }

      should_assign_to :plate
      should_assign_to :plate_editions
      should_respond_with :success
      should_render_template :_plate_editions
    end

    fast_context 'on XHR GET to :show' do
      setup do
        xhr :get, :show, :id => @edition_1.id
      end

      should_assign_to :plate_edition
      should_respond_with :success
      should_render_template "plate_editions/show.js.rjs"
    end

    fast_context 'on XHR GET to :preview' do
      setup do
        xhr :get, :preview, :id => @edition_1.id
      end

      should_assign_to :plate_edition
      should_respond_with :success
      should_render_template :_plate_edition_preview
    end

    fast_context 'on XHR GET to :new' do
      setup do
        xhr :get, :new, :plate_id => @plate.id, :copy_id => @edition_1.id
      end

      should_assign_to :plate_edition
      should_respond_with :success
      should_render_template "plate_editions/new.js.rjs"
    end

    fast_context 'on XHR GET to :edit' do
      setup { xhr :get, :edit, :id => @edition_1, :partial => "plate_editions/search_remote_edit_form" }

      should_assign_to :plate_edition
      should_respond_with :success
      should_render_template "plate_editions/edit.js.rjs"
    end

    context 'on XHR PUT to :update with valid attributes' do
      setup do
        @dom = "plate_edition_#{@edition_1.id}"
        @attributes = {
          :name       => 'new name',
          :content    => 'new content',
          :start_time => 1.month.from_now.change(:hour => 12, :min => 0, :sec => 0),
          :end_time   => 2.months.from_now.change(:hour => 12, :min => 0, :sec => 0) }
        @params = {
          :id            => @edition_1.id,
          :plate_edition => { "#{@edition_1.id}" => params_from_attributes(@attributes) },
        }
      end

      context 'with the Save button' do
        setup do
          @params[:commit_button] = 'Save'
        end

        fast_context 'and default partials' do
          setup do
            xhr(:put, :update, @params)
            @plate_edition = assigns(:plate_edition)
          end

          should_assign_to :plate_edition
          should_assign_to :update_notice
          should("update the name") { assert_equal(@attributes[:name], @plate_edition.name) }
          should("update the content") { assert_equal(@attributes[:content], @plate_edition.content) }
          should("update the start_time") { assert_equal(@attributes[:start_time], @plate_edition.start_time) }
          should("update the end_time") { assert_equal(@attributes[:end_time], @plate_edition.end_time) }
          should_respond_with :success
          should_render_template "plate_editions/update.js.rjs"

          # TODO - some js testing
        end
      end
    end

    context 'on XHR DELETE to :destroy' do
      # TODO - this
    end

    fast_context 'on GET to :search' do
      setup { get :search, :q => "current" }

      should_assign_to :plate_editions
      should "return edition_1 in the results" do
        assert assigns(:plate_editions).include?(@edition_1)
      end
      should_respond_with :success
      should_render_template "search"
    end
  end

end
