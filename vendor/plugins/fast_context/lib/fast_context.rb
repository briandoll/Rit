puts "Loading fast_context"
require 'shoulda/context'

module ShouldaContextExtensions
  def self.included(base)
    base.class_eval do
      alias_method_chain :build, :fast_context
      alias_method_chain :am_subcontext?, :fast_context
    end
  end

  def fast_context(name, &blk)
    @fast_subcontexts ||= []
    @fast_subcontexts << Shoulda::FastContext.new(name, self, &blk)
  end

  def build_with_fast_context
    build_without_fast_context
    @fast_subcontexts ||= []
    @fast_subcontexts.each {|f| f.build }
  end

  def am_subcontext_with_fast_context?
    parent.is_a?(Shoulda::Context) || parent.is_a?(Shoulda::FastContext)
  end
end

module Shoulda
  class FastContext < Context
    def create_test_from_should_hash
      test_name = ["test:", full_name, "should", "run_fast"].flatten.join(' ').to_sym

      if test_unit_class.instance_methods.include?(test_name.to_s)
        warn "  * WARNING: '#{test_name}' is already defined"
      end

      context = self
      test_unit_class.send(:define_method, test_name) do
        @shoulda_context = context
        @current_should = nil
        begin
          context.run_parent_setup_blocks(self)
          context.shoulds.each do |s| 
            @current_should = s
            s[:before].bind(self).call if s[:before] 
          end
          context.run_current_setup_blocks(self)

          context.shoulds.each {|should| should[:block].bind(self).call }
        rescue Test::Unit::AssertionFailedError => e
          error = Test::Unit::AssertionFailedError.new(["FAILED:", context.full_name, "should", "#{@current_should[:name]}:", e.message].flatten.join(' '))
          error.set_backtrace e.backtrace
          raise error
        ensure
          context.run_all_teardown_blocks(self)
        end
      end
    end

    def build
      create_test_from_should_hash
      subcontexts.each {|context| context.build }

      @fast_subcontexts ||= []
      @fast_subcontexts.each {|f| f.build }

      print_should_eventuallys
    end
  end
end

class ActiveSupport::TestCase
  def self.fast_context(name, &blk)
    if Shoulda.current_context
      Shoulda.current_context.fast_context(name, &blk)
    else
      context = Shoulda::FastContext.new(name, self, &blk)
      context.build
    end
  end  
end

Shoulda::Context.send :include, ShouldaContextExtensions
