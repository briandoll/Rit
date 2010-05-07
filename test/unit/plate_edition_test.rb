require 'test_helper'

class PlateEditionTest < ActiveSupport::TestCase
  subject { Factory(:plate_edition) }
  
  should_belong_to :plate
  should_belong_to :event
  
  # an edition must belong to a plate
  should_validate_presence_of :plate
  should_validate_presence_of :name
  
  should "validate uniqueness of plate scoped to event if belongs to event" do
    @plate = Factory(:plate)
    @pe_1 = Factory(:plate_edition, :plate => @plate)
    @pe_2 = Factory(:plate_edition, :plate => @plate)
    @event = Factory(:event)
    
    @pe_1.event = @event
    assert(@pe_1.save)
    
    @pe_2.event = @event
    assert_equal(false, @pe_2.save)
    assert_equal('is already part of this Event.  Remove the other Edition first.', @pe_2.errors.on('plate_id'))
  end
  
  fast_context "A new PlateEdition" do
    setup do
      @pe = PlateEdition.new
    end
    
    should "not be published" do
      assert_equal(false, @pe.publish)
    end
    
    should "not be scheduled" do
      assert_equal(nil, @pe.start_time)
      assert_equal(nil, @pe.end_time)
    end
  end
  
  context "A newly created PlateEdition" do
    setup do
      @pe = Factory(:plate_edition)
    end
    
    should "not be default if unpublished" do
      @pe.publish = false
      @pe.default_edition = true
      assert_equal(false, @pe.save)
      assert_equal("can't be set if not published", @pe.errors.on("default_edition"))
    end
    
    should "not have only an end_time" do
      @pe.start_time = nil
      @pe.end_time = 1.day.from_now
      assert_equal(false, @pe.save)
      assert_equal("can't be set without start_time", @pe.errors.on("end_time"))
    end
    
    should "not have an end_time earlier than start_time" do
      @pe.start_time = 1.day.from_now
      @pe.end_time = Time.now
      assert_equal(false, @pe.save)
      assert_equal("can't be earlier than start_time", @pe.errors.on("end_time"))
    end
    
    should "not be published without a start_time" do
      @pe.start_time = nil
      @pe.publish = true
      assert_equal(false, @pe.save)
      assert_equal("can't be set without a start_time", @pe.errors.on("publish"))
    end
    
    context "that is currently live" do
      setup do
        @pe.start_time = 1.day.ago
        @pe.end_time = 1.day.from_now
        @pe.save
      end
      
      should "return true when published and sent :live?" do
        @pe.publish = true
        @pe.save
        assert @pe.live?
      end
      
      should "return false when not published and sent :live?" do
        assert_equal(false, @pe.live?)
      end
    end
  end
  
  context "A PlateEdition belonging to an Event" do
    setup do
      @event = Factory(:event)
      @pe = Factory(:plate_edition)
      @pe.event = @event
      @pe.save
    end
    
    should "have the event's start and end times" do
      assert_equal(@event.start_time, @pe.start_time)
      assert_equal(@event.end_time, @pe.end_time)
    end
    
    should "not allow assignment to start_time and end_time" do
      assert_raise(ArgumentError) { @pe.start_time = Time.now }
      assert_raise(ArgumentError) { @pe.end_time = Time.now }
    end
    
    context "when removed from the event" do
      setup do
        @pe.event = nil
        @pe.save
      end
      
      should "still have the event's start and end times" do
        assert_equal(@event.start_time, @pe.start_time)
        assert_equal(@event.end_time, @pe.end_time)
      end
    end
  end
  
  
  #
  # effective times and conflicts
  #
  
  context "A Plate with a default plate edition," do
    setup do
      @plate = Factory(:plate)
      @default_start_time = Time.zone.local(2007, 1, 1)
      @default_end_time = Time.zone.local(2007, 1, 2)
      @default_edition = Factory(:default_plate_edition,
                                  :plate      => @plate,
                                  :start_time => @default_start_time,
                                  :end_time   => @default_end_time)
    end
    
    fast_context "default_edition" do
      should "return [beginning_of_time, default_start_time, default_end_time] when sent :effective_start_times" do
        # TODO - collapse these?
        assert_equal([Plate::BEGINNING_OF_TIME, @default_start_time, @default_end_time], 
          @default_edition.effective_start_times)
      end
      
      should "return [default_start_time, default_end_time, nil] when sent :effective_end_times" do
        assert_equal([@default_start_time, @default_end_time, nil], @default_edition.effective_end_times)
      end
      
      should "return [] when sent :conflicting_editions" do
        assert_equal([], @default_edition.conflicting_editions)
      end
      
      should "return false when sent :conflicting_editions?" do
        assert_equal(false, @default_edition.conflicting_editions?)
      end
      
      should "return nil when sent :current_end_time" do
        assert_equal(nil, @default_edition_current_end_time)
      end
    end
    
    context "and 2 non conflicting PlateEditions," do
      setup do
        @time_1 = Time.zone.local(2009, 9, 1, 9)
        @time_2 = Time.zone.local(2009, 9, 30, 17)
        @time_3 = Time.zone.local(2009, 10, 1, 9)
        @time_4 = Time.zone.local(2009, 10, 31, 17)
        
        @edition_1 = Factory(:published_plate_edition,
                              :name        => "edition 1",
                              :plate       => @plate,
                              :start_time  => @time_1,
                              :end_time    => @time_2)
        @edition_2 = Factory(:published_plate_edition,
                              :name        => "edition 2",
                              :plate       => @plate,
                              :start_time  => @time_3,
                              :end_time    => @time_4)
      end
      
      fast_context "edition_1" do
        should "return [time_1] when sent :effective_start_times" do
          assert_equal([@time_1], @edition_1.effective_start_times)
        end
        
        should "return [time_2] when sent :effective_end_times" do
          assert_equal([@time_2], @edition_1.effective_end_times)
        end
        
        should "return [[time_1, time_2]] when sent :active_times" do
          assert_equal([[@time_1, @time_2]], @edition_1.active_times)
        end
        
        should "return [] when sent :conflicting_editions" do
          assert_equal([], @edition_1.conflicting_editions)
        end
        
        should "return false when sent :conflicting_editions?" do
          assert_equal(false, @edition_1.conflicting_editions?)
        end
        
        should "return time_2 when sent :current_end_time with a time between time_1 and time_2" do
          assert_equal(@time_2, @edition_1.current_end_time(Time.zone.local(2009, 9, 15)))
        end
        
        should "raise IndexError when sent :current_end_time" do
          assert_raise(IndexError) { @edition_1.current_end_time }
        end
      end
      
      context "and 1 conflicting edition starting between time_1 and time_2 and ending between time_3 and time_4," do
        setup do
          @time_1_5 = Time.zone.local(2009, 9, 15, 9)
          @time_3_5 = Time.zone.local(2009, 10, 15, 9)
          
          @new_edition = Factory(:published_plate_edition,
                                  :name       => "new edition",
                                  :plate      => @plate,
                                  :start_time => @time_1_5,
                                  :end_time   => @time_3_5)
        end
        
        fast_context "edition_1" do
          setup do
            @e = @edition_1
          end
          
          should "return [time_1] when sent :effective_start_times" do
            assert_equal([@time_1], @e.effective_start_times)
          end
          
          should "return [time_1_5] when sent :effective_end_times" do
            assert_equal([@time_1_5], @e.effective_end_times)
          end
          
          should "return [[time_1, time_1_5]] when sent :active_times" do
            assert_equal([[@time_1, @time_1_5]], @e.active_times)
          end
          
          should "return [new_edition] when sent :conflicting_editions" do
            assert_equal([@new_edition], @e.conflicting_editions)
          end
        end
        
        fast_context "new_edition" do
          setup do
            @e = @new_edition
          end
          
          should "return [time_1_5] when sent :effective_start_times" do
            assert_equal([@time_1_5], @e.effective_start_times)
          end
          
          should "return [time_3] when sent :effective_end_times" do
            assert_equal([@time_3], @e.effective_end_times)
          end
          
          should "return [[time_1_5, time_3]] when sent :active_times" do
            assert_equal([[@time_1_5, @time_3]], @e.active_times)
          end
          
          should "return [edition_1, edition_2] when sent :conflicting_editions" do
            assert_equal([@edition_1, @edition_2], @e.conflicting_editions)
          end
        end
        
        fast_context "edition_2" do
          setup do
            @e = @edition_2
          end
          
          should "return [time_3] when sent :effective_start_times" do
            assert_equal([@time_3], @e.effective_start_times)
          end
          
          should "return [time_4] when sent :effective_end_times" do
            assert_equal([@time_4], @e.effective_end_times)
          end
          
          should "return [[time_3, time_4]] when sent :active_times" do
            assert_equal([[@time_3, @time_4]], @e.active_times)
          end
          
          should "return [new_edition] when sent :conflicting_editions" do
            assert_equal([@new_edition], @e.conflicting_editions)
          end
        end
      end
      
      context "and 1 conflicting edition starting at time_1 and not ending," do
        setup do
          @new_edition = Factory(:published_plate_edition,
                                  :name       => "new edition",
                                  :plate      => @plate,
                                  :start_time => @time_1)
        end
        
        fast_context "edition_1" do
          setup do
            @e = @edition_1
          end
          
          should "return [] when sent :effective_start_times" do
            assert_equal([], @e.effective_start_times)
          end
          
          should "return [] when sent :effective_end_times" do
            assert_equal([], @e.effective_end_times)
          end
          
          should "return [] when sent :active_times" do
            assert_equal([], @e.active_times)
          end
          
          should "return [new_edition] when sent :conflicting_editions" do
            assert_equal([@new_edition], @e.conflicting_editions)
          end
        end
        
        fast_context "new_edition" do
          setup do
            @e = @new_edition
          end
          
          should "return [time_1, time_4] when sent :effective_start_times" do
            assert_equal([@time_1, @time_4], @e.effective_start_times)
          end
          
          should "return [time_3, nil] when sent :effective_end_times" do
            assert_equal([@time_3, nil], @e.effective_end_times)
          end
          
          should "return [[time_1, time_3], [time_4, nil] when sent :active_times" do
            assert_equal([[@time_1, @time_3], [@time_4, nil]], @e.active_times)
          end
          
          should "return [edition_1, edition_2] when sent :conflicting_editions" do
            assert_equal([@edition_1, @edition_2], @e.conflicting_editions)
          end

          should "return @time_3 when sent :current_end_time at @time_1 + 1 day" do
            assert_equal(@time_3, @e.current_end_time(@time_1 + 1.day))
          end
          
          should "return nil when sent :current_end_time at @time_4 + 1 day" do
            assert_equal(nil, @e.current_end_time(@time_4 + 1.day))
          end
          
          should "raise IndexError when sent :current_end_time at @time_3" do
            assert_raise(IndexError) { @e.current_end_time(@time_3) }
          end
        end
        
        fast_context "edition_2" do
          setup do
            @e = @edition_2
          end
          
          should "return [time_3] when sent :effective_start_times" do
            assert_equal([@time_3], @e.effective_start_times)
          end
          
          should "return [time_4] when sent :effective_end_times" do
            assert_equal([@time_4], @e.effective_end_times)
          end
          
          should "return [[time_3, time_4]] when sent :active_times" do
            assert_equal([[@time_3, @time_4]], @e.active_times)
          end
          
          should "return [new_edition] when sent :conflicting_editions" do
            assert_equal([@new_edition], @e.conflicting_editions)
          end
        end
      end
    end
  end
  
end
