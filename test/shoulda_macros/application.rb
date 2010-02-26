class Test::Unit::TestCase
  
  def self.should_publish(description, &block)
    context "should publish #{description}" do
      setup do
        @edition = instance_eval(&block)
      end
      should_respond_with(:success)
      should_assign_to(:edition)
      should "assign #{description} to edition" do
        assert_equal(@edition, assigns(:edition))
      end
      should_render_without_layout
      should "render #{description} content" do
        assert_equal(@edition.content, @response.body)
      end
    end
  end
  
end
