require File.join(File.dirname(__FILE__), '..', 'test_helper')

class MockAppointment
  attr_accessor :start_time, :end_time
  
  def initialize(opts={})
    @start_time = opts.fetch(:start_time, nil)
    @end_time = opts.fetch(:end_time, nil)
  end
end

class SchedulerTest < ActiveSupport::TestCase
  #
  # Basic Tests
  #
  context "The Scheduler" do
    setup do
      @default_start_time = Time.zone.local(2007, 1, 1)
      @default_end_time = Time.zone.local(2007, 1, 2)
      @default_appointment = MockAppointment.new(:start_time => @default_start_time,
                                                 :end_time   => @default_end_time)
      @endless_appointment = MockAppointment.new(:start_time => @default_start_time,
                                                 :end_time   => nil)
    end

    should "return an empty hash when sent :timeline with no appointments and no default" do
      start_times = Scheduler.timeline(nil)
      assert_equal(0, start_times.size)
    end

    should "return an empty hash when sent :timeline with no appointments and a default" do
      start_times = Scheduler.timeline(nil, @default_appointment)
      assert_equal(0, start_times.size)
    end

    should "return a hash when sent :timeline with an appointment that ends and no default" do
      start_times = Scheduler.timeline([@default_appointment])
      assert_equal(2, start_times.size)
      assert_contains_at(start_times, @default_appointment, @default_start_time)
      assert_contains_at(start_times, nil, @default_end_time)
    end

    should "return a hash when sent :timeline with an appointment that doesn't end and no default" do
      start_times = Scheduler.timeline([@endless_appointment])
      assert_equal(1, start_times.size)
      assert_contains_at(start_times, @endless_appointment, @default_start_time)
    end

    should "return a hash when sent :timeline with an appointment that ends and a default" do
      start_times = Scheduler.timeline([@default_appointment], @default_appointment)
      assert_equal(2, start_times.size)
      assert_contains_at(start_times, @default_appointment, @default_start_time)
      assert_contains_at(start_times, @default_appointment, @default_end_time)
    end

    should "return a hash when sent :timeline with an appointment that doesnt' end and a default" do
      start_times = Scheduler.timeline([@endless_appointment], @default_appointment)
      assert_equal(1, start_times.size)
      assert_contains_at(start_times, @endless_appointment, @default_start_time)
    end
  end


  #
  # Conflicting Tests
  #
  context "The Scheduler with a default appointment" do
    setup do
      @default_start_time = Time.zone.local(2007, 1, 1)
      @default_end_time = Time.zone.local(2007, 1, 2)
      @default_appointment = MockAppointment.new(:start_time => @default_start_time,
                                                 :end_time   => @default_end_time)
    end


    # Timeline:
    #
    # <=================================================>
    #     |------------|
    #                       |------------|
    context "and 2 non conflicting appointments," do
      setup do
        @current_time = Time.zone.now.quantized_to_hour
        @time_1 = @current_time + 1.day
        @time_2 = @current_time + 1.day + 1.month
        @time_3 = @current_time + 1.day + 1.month + 1.day
        @time_4 = @current_time + 1.day + 1.month + 1.day + 1.month

        @appointment_1 = MockAppointment.new(:start_time  => @time_1,
                                             :end_time    => @time_2)
        @appointment_2 = MockAppointment.new(:start_time  => @time_3,
                                             :end_time    => @time_4)
        @appointments = [@appointment_1, @appointment_2]
      end

      fast_context "when sent :timeline, returns a hash that" do
        setup do
          @start_times = Scheduler.timeline(@appointments, @default_appointment)
        end

        should "contain 4 start times" do
          assert_equal(4, @start_times.size)
        end

        should "contain appointment_1 at time_1" do
          assert_contains_at(@start_times, @appointment_1, @time_1)
        end

        should "contain default_appointment at time_2" do
          assert_contains_at(@start_times, @default_appointment, @time_2)
        end

        should "contain appointment_2 at time_3" do
          assert_contains_at(@start_times, @appointment_2, @time_3)
        end

        should "contain default_appointment at time_4" do
          assert_contains_at(@start_times, @default_appointment, @time_4)
        end
      end


      # Timeline:
      #
      # <=================================================>
      #     |------------|
      #           |----------------|
      #                       |------------|
      context "and 1 conflicting appointment starting between time_1 and time_2 and ending between time_3 and time_4," do
        setup do
          @time_1_5 = @time_1 + 15.days
          @time_3_5 = @time_3 + 15.days

          @new_appointment = MockAppointment.new(:start_time => @time_1_5,
                                                 :end_time   => @time_3_5)
          @appointments << @new_appointment
          @appointments = @appointments.sort_by { |a| a.start_time }
        end

        fast_context "when sent :timeline, returns a hash that" do
          setup do
            @start_times = Scheduler.timeline(@appointments, @default_appointment)
          end

          should "contain 4 start times" do
            assert_equal(4, @start_times.size)
          end

          should "contain appointment_1 at time_1" do
            assert_contains_at(@start_times, @appointment_1, @time_1)
          end

          should "contain new_appointment at time_1_5" do
            assert_contains_at(@start_times, @new_appointment, @time_1_5)
          end

          should "contain appointment_2 at time_3" do
            assert_contains_at(@start_times, @appointment_2, @time_3)
          end

          should "contain default_appointment at time_4" do
            assert_contains_at(@start_times, @default_appointment, @time_4)
          end
        end

      end


      # Timeline:
      #
      # <=================================================>
      #     |------------|
      #     |--------------------------------------------->
      #                       |------------|
      context "and 1 conflicting appointment starting at time_1 and not ending," do
        setup do
          @new_appointment = MockAppointment.new(:start_time => @time_1, :end_time => nil)
          @appointments = [@appointment_1, @new_appointment, @appointment_2]
        end

        fast_context "when sent :timeline, returns a hash that" do
          setup do
            @start_times = Scheduler.timeline(@appointments, @default_appointment)
          end

          should "contain 4 start times" do
            assert_equal(3, @start_times.size)
          end

          should "contain new_appointment at time_1" do
            assert_contains_at(@start_times, @new_appointment, @time_1)
          end

          should "contain appointment_2 at time_3" do
            assert_contains_at(@start_times, @appointment_2, @time_3)
          end

          should "contain new_appointment at time_4" do
            assert_contains_at(@start_times, @new_appointment, @time_4)
          end
        end
      end
    end


    # Timeline:
    #
    # <=================================================>
    #     |------------------------|
    #           |------------|
    #                                    |--------|
    context "and three appointments arranged as so" do
      setup do
        # Create 6 times, all 5 days apart, starting with tomorrow
        now = Time.zone.now + 1.day
        (0..5).each do |n|
          eval "@time_#{n+1} = now.change(:hour => 12) + (5*n).days"
        end

        @containing_appointment = MockAppointment.new(:start_time => @time_1, :end_time => @time_4)
        @short_appointment = MockAppointment.new(:start_time => @time_2, :end_time => @time_3)
        @future_appointment = MockAppointment.new(:start_time => @time_5, :end_time => @time_6)
        @appointments = [@containing_appointment, @short_appointment, @future_appointment]
      end

      fast_context "when sent :timeline, returns a hash that" do
        setup do
          @start_times = Scheduler.timeline(@appointments, @default_appointment)
        end

        should "contain 6 start times" do
          @start_times.keys.sort.each do |k|
          end
          assert_equal(6, @start_times.size)
        end

        should "contain containing_appointment at time_1" do
          assert_contains_at(@start_times, @containing_appointment, @time_1)
        end

        should "contain short_appointment at time_2" do
          assert_contains_at(@start_times, @short_appointment, @time_2)
        end

        should "contain containing_appointment at time_3" do
          assert_contains_at(@start_times, @containing_appointment, @time_3)
        end

        should "contain default_appointment at time_4" do
          assert_contains_at(@start_times, @default_appointment, @time_4)
        end

        should "contain future_appointment at time_5" do
          assert_contains_at(@start_times, @future_appointment, @time_5)
        end

        should "contain default_appointment at time_6" do
          assert_contains_at(@start_times, @default_appointment, @time_6)
        end
      end
    end
  end

  private

  def assert_contains_at(hash, value, key)
    assert(hash.key? key)
    assert_equal(value, hash[key])
  end

end