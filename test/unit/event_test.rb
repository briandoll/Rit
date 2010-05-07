require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should_have_many :plate_editions
  should_have_many :plates, :through => :plate_editions

  should_validate_presence_of :name, :start_time, :end_time

  context "A new Event" do
    setup do
      @event = Event.new
    end

    should "have no plate_editions" do
      assert_equal([], @event.plate_editions)
    end
  end

  context "A newly created Event" do
    setup do
      @event = Factory(:event)
    end

    should "not have an end_time earlier than the start_time" do
      @event.start_time = 1.day.from_now
      @event.end_time = Time.now
      assert_equal(false, @event.save)
      assert_equal("can't be earlier than start_time", @event.errors.on('end_time'))
    end

    context "that is scheduled to run now" do
      setup do
        @event.start_time = 1.day.ago
        @event.end_time = 1.day.from_now
      end

      should "return true when published and sent :live?" do
        @event.publish = true
        assert(@event.live?)
      end

      should "return false when no published and sent :live?" do
        assert_equal(false, @event.live?)
      end
    end

    context "with PlateEditions" do
      setup do
        # mysql truncates usecs, reload to compare times with other records
        @event.reload
        @edition_1 = Factory(:plate_edition)
        @edition_2 = Factory(:plate_edition)
        @event.plate_editions << @edition_1
        @event.plate_editions << @edition_2
      end

      should "have PlateEditions with the same times" do
        assert(@event.plate_editions.all? { |pe| pe.start_time == @event.start_time })
        assert(@event.plate_editions.all? { |pe| pe.end_time == @event.end_time })
      end

      context "when times are changed" do
        setup do
          @event.start_time += 1.day
          @event.end_time -= 1.hour
          @event.save
          @event.reload
        end

        should "have PlateEditions with the same times" do
          assert(@event.plate_editions.all? { |pe| pe.start_time == @event.start_time })
          assert(@event.plate_editions.all? { |pe| pe.end_time == @event.end_time })
        end
      end
    end
  end
end
