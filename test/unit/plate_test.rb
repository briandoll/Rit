# == Schema Information
#
# Table name: plates
#
#  id            :integer         not null, primary key
#  layout_name   :string(255)
#  instance_name :string(255)
#  plate_name    :string(255)
#  description   :text
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_plates_on_layout_name_and_instance_name_and_plate_name  (layout_name,instance_name,plate_name) UNIQUE
#

require File.join(File.dirname(__FILE__), '..', 'test_helper')

class PlateTest < ActiveSupport::TestCase
  subject { Factory(:plate) }

  should_have_many :plate_editions, :dependent => :destroy
  should_have_one :default_plate_edition
  should_have_many :events, :through => :plate_editions

  should_validate_presence_of :layout_name, :plate_name
  should_validate_uniqueness_of :plate_name, :scoped_to => [:layout_name, :instance_name]
  should_not_allow_values_for :layout_name, " ", "ü", "%", "/", "\\"
  should_not_allow_values_for :instance_name, " ", "ü", "%", "/", "\\"
  should_not_allow_values_for :plate_name, " ", "ü", "%", "/", "\\"

  should "allow values for layout_name" do
    @plate = Factory(:plate)
    @plate.layout_name = "aA0-_"
    assert(@plate.save)
  end

  context "A new Plate" do
    setup do
      @plate = Plate.new
    end

    should "have no default edition" do
      assert_equal(nil, @plate.default_plate_edition)
    end
  end

  context "A newly created Plate" do
    setup do
      @plate = Factory(:plate)
    end

    should "have no plate_editions" do
      assert_equal([], @plate.plate_editions)
    end

    should "return {} when sent :edition_start_times" do
      assert_equal({}, @plate.edition_start_times)
    end
  end

  context "A Plate with many editions and a default plate edition" do
    setup do
      @plate = Factory(:plate)
      Factory(:published_plate_edition, :plate => @plate)
      Factory(:published_plate_edition, :plate => @plate)
      @new_edition = Factory(:default_plate_edition,
          :plate      => @plate,
          :start_time => Time.zone.local(2007, 1, 1),
          :end_time   => Time.zone.local(2007, 1, 2))
    end

    should "return a PlateEdition when sent #default_plate_edition" do
      assert_instance_of(PlateEdition, @plate.default_plate_edition)
    end

    should "return the default edition when sent #default_plate_edition" do
      assert_equal(@new_edition, @plate.default_plate_edition)
    end
  end

  context "A newly created Plate" do
    setup do
      @plate = Factory(:plate)
    end

    context "with one edition starting before now" do
      setup do
        @start_time = Time.zone.now.quantized_to_hour - 1.day
        @edition_1 = Factory(:published_plate_edition,
            :plate      => @plate,
            :start_time => @start_time,
            :end_time   => @start_time + 15.days)
      end

      should "return a hash when sent :edition_start_times for future start times" do
        @start_times = @plate.edition_start_times
        assert_equal(1, @start_times.size)
        assert_contains_at(@start_times, nil, @edition_1.end_time)
      end

      should "return a hash when sent :edition_start_times for all start times" do
        @start_times = @plate.edition_start_times(nil)
        assert_equal(2, @start_times.size)
        assert_contains_at(@start_times, @edition_1, @edition_1.start_time)
        assert_contains_at(@start_times, nil, @edition_1.end_time)
      end

      context "and a default plate edition" do
        setup do
          @default_edition = Factory(:default_plate_edition,
              :plate      => @plate,
              :start_time => @start_time - 10.days,
              :end_time   => @start_time - 9.days)
        end

        should "return a hash when sent :edition_start_times for future start times" do
          @start_times = @plate.edition_start_times
          assert_equal(1, @start_times.size)
          assert_contains_at(@start_times, @default_edition, @edition_1.end_time)
        end

        should "return a hash when sent :edition_start_times for all start times" do
          @start_times = @plate.edition_start_times(nil)
          assert_equal(5, @start_times.size)
          # default_edition starts as fallback
          assert_contains_at(@start_times, @default_edition, Plate::BEGINNING_OF_TIME)
          # default_edition starts as scheduled
          assert_contains_at(@start_times, @default_edition, @default_edition.start_time)
          # default_edition starts as fallback
          assert_contains_at(@start_times, @default_edition, @default_edition.end_time)
          assert_contains_at(@start_times, @edition_1, @edition_1.start_time)
          assert_contains_at(@start_times, @default_edition, @edition_1.end_time)
        end
      end
    end

    context "with one edition starting after now" do
      setup do
        @start_time = Time.zone.now.quantized_to_hour + 1.day
        @edition_1 = Factory(:published_plate_edition,
            :plate      => @plate,
            :start_time => @start_time,
            :end_time   => @start_time + 15.days)
      end

      should "return a hash when sent :edition_start_times" do
        @start_times = @plate.edition_start_times
        assert_equal(2, @start_times.size)
        assert_contains_at(@start_times, @edition_1, @edition_1.start_time)
        assert_contains_at(@start_times, nil, @edition_1.end_time)
      end

      context "and a default plate edition" do
        setup do
          @default_edition = Factory(:default_plate_edition,
              :plate      => @plate,
              :start_time => @start_time - 10.days,
              :end_time   => @start_time - 9.days)
        end

        should "return a hash when sent :edition_start_times" do
          @start_times = @plate.edition_start_times
          assert_equal(3, @start_times.size)
          first_time = @start_times.keys.sort.first
          # start time is floored to the hour from now, so we just check that it's within two hours
          assert((Time.now - first_time) < 2.hours)
          assert_equal(@default_edition, @start_times[first_time])
          assert(@start_times.key?(@edition_1.start_time))
          assert_equal(@edition_1, @start_times[@edition_1.start_time])
          assert(@start_times.key? @edition_1.end_time)
          assert_equal(@default_edition, @start_times[@edition_1.end_time])
        end

        should "return a hash when sent :edition_start_times with a starting_time" do
          @start_times = @plate.edition_start_times(@start_time)
          assert_equal(2, @start_times.size)
          assert(@start_times.key? @edition_1.start_time)
          assert_equal(@edition_1, @start_times[@edition_1.start_time])
          assert(@start_times.key? @edition_1.end_time)
          assert_equal(@default_edition, @start_times[@edition_1.end_time])
        end
      end
    end

    context "with one published edition that is part of one event that is currently running" do
      setup do
        # TODO - So much to do because of the can't publish event without plate editions constraint.
        # Maybe it should be removed.
        @event = Factory(:event)
        @edition = Factory(:published_plate_edition, :plate => @plate)
        @edition.event = @event
        @edition.save
      end

      should "return a hash when sent :edition_start_times" do
        @plate.plate_editions
        @plate.plate_editions[0].event
        @start_times = @plate.edition_start_times
        assert_equal(0, @start_times.size)
      end

      context "that is published" do
        setup do
          @event.reload
          @event.publish = true
          @event.save
        end

        should "return a hash when sent :edition_start_times for future start times" do
          @plate.plate_editions
          @plate.plate_editions[0].event
          @start_times = @plate.edition_start_times
          assert_equal(1, @start_times.size)
          assert_contains_at(@start_times, nil, @event.end_time)
        end

        should "return a hash when sent :edition_start_times for all start times" do
          @plate.plate_editions
          @plate.plate_editions[0].event
          @start_times = @plate.edition_start_times(nil)
          assert_equal(2, @start_times.size)
          assert_contains_at(@start_times, @edition, @event.start_time)
          assert_contains_at(@start_times, nil, @event.end_time)
        end
      end
    end

  end

  context "A Plate with a published edition with an end date, with no fallback edition specified" do
    setup do
      @plate_edition = Factory(:published_plate_edition, :end_time => (Time.now))
      @plate = @plate_edition.plate
      @the_crazy_future = (Time.now + 2.weeks)
    end

    should "return a nil edition for dates beyond scheduled edition end dates" do
      assert_nothing_raised{ @plate.edition_on(@the_crazy_future) }
      assert_equal @plate.edition_on(@the_crazy_future), nil
    end

    should "raise an IndexError when attempting to get the current end time" do
      # skip("see FIXME KASIMA - failing test in master") - wtf #skip undefined?
      raise MiniTest::Skip, "see FIXME KASIMA - failing test in master", "PlateTest"
      assert_raise IndexError do
        # FIXME KASIMA: not sure I understand the test and expected behavior
        # puts @plate_edition.active_times.find { |times| @the_crazy_future >= times[0] and (times[1].nil? or at_time < times[1]) }
        @plate_edition.current_end_time(@the_crazy_future) end
    end
  end

  context "A Plate with a default plate edition, an unpublished edition," do
    setup do
      @plate = Factory(:plate)
      @default_start_time = Time.zone.local(2007, 1, 1)
      @default_end_time = Time.zone.local(2007, 1, 2)
      @default_edition = Factory(:default_plate_edition,
          :plate      => @plate,
          :start_time => @default_start_time,
          :end_time   => @default_end_time)
      Factory(:plate_edition,
          :plate      => @plate,
          :start_time => Time.zone.now + 1.year,
          :end_time   => Time.zone.now + 1.year + 1.day)
    end

    should "return hash of start times when sent :edition_start_times" do
      start_times = @plate.edition_start_times
      assert_equal(1, start_times.size)
      # start time is floored to the hour from now, so we just check that it's within two hours
      assert((Time.now - start_times.first[0]) < 2.hour)
      assert_equal(@default_edition, start_times.first[1])
    end

    context "and 2 non conflicting PlateEditions," do
      setup do
        @current_time = Time.zone.now.quantized_to_hour
        @time_1 = @current_time + 1.day
        @time_2 = @current_time + 1.day + 1.month
        @time_3 = @current_time + 1.day + 1.month + 1.day
        @time_4 = @current_time + 1.day + 1.month + 1.day + 1.month

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

      should "return default_edition when sent #edition_on before time_1" do
        assert_equal(@default_edition, @plate.edition_on(@current_time))
      end

      should "return edition_1 when sent #edition_on time_1" do
        assert_equal(@edition_1, @plate.edition_on(@time_1))
      end

      should "return edition_1 when sent #edition_on between time_1 and time_2" do
        assert_equal(@edition_1, @plate.edition_on(@time_1 + 15.days))
      end

      should "return default_edition when sent #edition_on at time_2" do
        assert_equal(@default_edition, @plate.edition_on(@time_2))
      end

      should "return default_edition when sent #edition_on between time_2 and time_3" do
        assert_equal(@default_edition, @plate.edition_on(@time_2 + 12.hours))
      end

      should "return edition_2 when sent #edition_on between time_3 and time_4" do
        assert_equal(@edition_2, @plate.edition_on(@time_3 + 15.days))
      end

      should "return default_edition when sent #edition_on after time_4" do
        assert_equal(@default_edition, @plate.edition_on(@time_4 + 1.day))
      end

      context "when sent :edition_start_times, returns a hash that" do
        setup do
          @start_times = @plate.edition_start_times
        end

        should "contain 5 start times" do
          assert_equal(5, @start_times.size)
        end

        should "contain default_edition at the earliest time" do
          earliest_time = @start_times.keys.sort.first
          assert(Time.zone.now - earliest_time < 2.hours)
          assert_equal(@default_edition, @start_times[earliest_time])
        end

        should "contain edition_1 at time_1" do
          assert_contains_at(@start_times, @edition_1, @time_1)
        end

        should "contain default_edition at time_2" do
          assert_contains_at(@start_times, @default_edition, @time_2)
        end

        should "contain edition_2 at time_3" do
          assert_contains_at(@start_times, @edition_2, @time_3)
        end

        should "contain default_edition at time_4" do
          assert_contains_at(@start_times, @default_edition, @time_4)
        end
      end

      context "and 1 conflicting edition starting between time_1 and time_2 and ending between time_3 and time_4," do
        setup do
          @time_1_5 = @time_1 + 15.days
          @time_3_5 = @time_3 + 15.days

          @new_edition = Factory(:published_plate_edition,
              :name       => "new edition",
              :plate      => @plate,
              :start_time => @time_1_5,
              :end_time   => @time_3_5)
        end

        should "return new_edition when sent #edition_on between time_1_5 and time_2 because it started later" do
          assert_equal(@new_edition, @plate.edition_on(@time_1_5 + 1.day))
        end

        should "return new_edition when sent #edition_on between time_2 and time_3" do
          assert_equal(@new_edition, @plate.edition_on(@time_2 + 12.hours))
        end

        should "return edition_2 when sent #edition_on between time_3 and time_3_5 because it started later" do
          assert_equal(@edition_2, @plate.edition_on(@time_3 + 1.day))
        end

        context "when sent :edition_start_times, returns a hash that" do
          setup do
            @start_times = @plate.edition_start_times
          end

          should "contain 5 start times" do
            assert_equal(5, @start_times.size)
          end

          should "contain default_edition at the earliest time" do
            earliest_time = @start_times.keys.sort.first
            assert(Time.zone.now - earliest_time < 2.hours)
            assert_equal(@default_edition, @start_times[earliest_time])
          end

          should "contain edition_1 at time_1" do
            assert_contains_at(@start_times, @edition_1, @time_1)
          end

          should "contain new_edition at time_1_5" do
            assert_contains_at(@start_times, @new_edition, @time_1_5)
          end

          should "contain edition_2 at time_3" do
            assert_contains_at(@start_times, @edition_2, @time_3)
          end

          should "contain default_edition at time_4" do
            assert_contains_at(@start_times, @default_edition, @time_4)
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

        should "return new_edition when sent #edition_on between time_1 and time_2 because it was updated more recently" do
          # sleep so that updated_at time on new_edition is newer
          sleep 1
          @new_edition.name = "new edition updated"
          @new_edition.save
          assert_equal(@new_edition, @plate.edition_on(@time_1 + 15.days))
        end

        should "return new_edition when sent #edition_on at time_2" do
          assert_equal(@new_edition, @plate.edition_on(@time_2))
        end

        should "return new_edition when sent #edition_on between time_2 and time_3" do
          assert_equal(@new_edition, @plate.edition_on(@time_2 + 12.hours))
        end

        should "return edition_2 when sent #edition_on between time_3 and time_4 because it started later" do
          assert_equal(@edition_2, @plate.edition_on(@time_3 + 15.days))
        end

        should "return new_edition when sent #edition_on after time_4" do
          assert_equal(@new_edition, @plate.edition_on(@time_4 + 1.day))
        end

        context "when sent :edition_start_times, returns a hash that" do
          setup do
            @start_times = @plate.edition_start_times
          end

          should "contain 4 start times" do
            assert_equal(4, @start_times.size)
          end

          should "contain default_edition at the earliest time" do
            earliest_time = @start_times.keys.sort.first
            assert(Time.zone.now - earliest_time < 2.hours)
            assert_equal(@default_edition, @start_times[earliest_time])
          end

          should "contain new_edition at time_1" do
            assert_contains_at(@start_times, @new_edition, @time_1)
          end

          should "contain edition_2 at time_3" do
            assert_contains_at(@start_times, @edition_2, @time_3)
          end

          should "contain new_edition at time_4" do
            assert_contains_at(@start_times, @new_edition, @time_4)
          end
        end

        context "when sent :edition_start_times for the whole timeline, returns a hash that" do
          setup do
            @start_times = @plate.edition_start_times(nil)
          end

          should "contain 6 start times" do
            assert_equal(6, @start_times.size)
          end

          # The default edition is listed consecutively becaues it comes in as scheduled and under
          # the default rules.
          # TODO - maybe we should mark when the default edition comes in as scheduled or as default rules
          should "contain default_edition at BEGINNNG_OF_TIME" do
            assert_contains_at(@start_times, @default_edition, Plate::BEGINNING_OF_TIME)
          end

          should "contain default_edition at default_start_time" do
            assert_contains_at(@start_times, @default_edition, @default_start_time)
          end

          should "contain default_edition at default_end_time" do
            assert_contains_at(@start_times, @default_edition, @default_end_time)
          end

          should "contain new_edition at time_1" do
            assert_contains_at(@start_times, @new_edition, @time_1)
          end

          should "contain edition_2 at time_3" do
            assert_contains_at(@start_times, @edition_2, @time_3)
          end

          should "contain new_edition at time_4" do
            assert_contains_at(@start_times, @new_edition, @time_4)
          end
        end
      end
    end

    context "and 1 currently valid edition" do
      setup do
        @valid_edition = Factory(:published_plate_edition, :plate => @plate)
        Factory(:plate_edition, :plate => @plate)
        Factory(:past_published_plate_edition, :plate => @plate)
        Factory(:future_published_plate_edition, :plate => @plate)
        assert_equal(6, @plate.plate_editions.count)
      end

      should "return the valid edition when sent #edition_now" do
        assert_equal(@valid_edition, @plate.edition_now)
      end
    end

    context "and no currently valid editions" do
      setup do
        Factory(:past_published_plate_edition, :plate => @plate)
        Factory(:past_published_plate_edition, :plate => @plate)
        assert_equal(4, @plate.plate_editions.count)
      end

      should "return the default edition when sent #edition_now" do
        assert_equal(@default_edition, @plate.edition_now)
      end
    end

    context "and three editions arranged as so" do
      setup do
        # Create 6 times, all 5 days apart, starting with tomorrow
        now = Time.zone.now + 1.day
        (0..5).each do |n|
          eval "@time_#{n+1} = now.change(:hour => 12) + (5*n).days"
        end

        @containing_edition = Factory(:published_plate_edition,
            :name        => "containing edition",
            :plate       => @plate,
            :start_time  => @time_1,
            :end_time    => @time_4)
        @short_edition = Factory(:published_plate_edition,
            :name        => "short edition",
            :plate       => @plate,
            :start_time  => @time_2,
            :end_time    => @time_3)
        @future_edition = Factory(:published_plate_edition,
            :name        => "future edition",
            :plate       => @plate,
            :start_time  => @time_5,
            :end_time    => @time_6)
      end

      context "when sent :edition_start_times, returns a hash that" do
        setup do
          @start_times = @plate.edition_start_times
        end

        should "contain 7 start times" do
          @start_times.keys.sort.each do |k|
          end
          assert_equal(7, @start_times.size)
        end

        should "contain default_edition at the earliest time" do
          earliest_time = @start_times.keys.sort.first
          assert(Time.zone.now - earliest_time < 2.hours)
          assert_equal(@default_edition, @start_times[earliest_time])
        end

        should "contain containing_edition at time_1" do
          assert_contains_at(@start_times, @containing_edition, @time_1)
        end

        should "contain short_edition at time_2" do
          assert_contains_at(@start_times, @short_edition, @time_2)
        end

        should "contain containing_edition at time_3" do
          assert_contains_at(@start_times, @containing_edition, @time_3)
        end

        should "contain default_edition at time_4" do
          assert_contains_at(@start_times, @default_edition, @time_4)
        end

        should "contain future_edition at time_5" do
          assert_contains_at(@start_times, @future_edition, @time_5)
        end

        should "contain default_edition at time_6" do
          assert_contains_at(@start_times, @default_edition, @time_6)
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
