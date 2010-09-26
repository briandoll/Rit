class Scheduler
  class << self
    # Given this timeline of appointments and a start_time before time_1, with default_appointment = nil:
    #
    # times          |     1               2   3   4             5     6
    #                | <===^===============^===^===^=============^=====^===>
    # appointment_1  |     |---------------|
    # appointment_2  |                         |-----------------------|
    # appointment_3  |                             |--------------|
    #
    # Returns the following hash of start times:
    # {
    #   time_1      => appointment_1,
    #   time_2      => nil,
    #   time_3      => appointment_2,
    #   time_4      => appointment_3,
    #   time_5      => appointment_2,
    #   time_6      => nil
    # }
    def timeline(sorted_appointments, default_appointment = nil)
      @scheduled_times_hash = {}
      if sorted_appointments.all? { |a| a.respond_to?(:start_time) and a.respond_to?(:end_time) }
        @sorted_appointments = sorted_appointments
        @default_appointment = default_appointment
        @appointments_stack = []
        first_appointment = sorted_appointments.first
        schedule_next(first_appointment.start_time, first_appointment)
      else
        raise ArgumentError, "objects do not have start_time and end_time"
      end unless sorted_appointments.blank?
      @scheduled_times_hash
    end

    private

    # Schedules the current edition into the times_hash at start time and continues to all subsequent
    # editions editions, including default editions.  If current edition is null, checks to see if
    # hash should start at the first scheduled edition in the editions parameter or the default edition.
    #
    # @start_time -       time to start the hash at (if start time is in the middle of a scheduled edition,
    #                     the hash will start at the start_time of the scheduled edition
    # @current_appointment -  edition to stare in the hash at start_time key
    # @editions -         sorted list of scheduled editions
    # @editions_stack -   stack of possibly conflicting editions at start_time
    def schedule_next(start_time, current_appointment)
      if current_appointment.nil?
        # A nil current_appointment means we are starting with the default edition.  However, if there
        # is a scheduled edition that starts at start_time, start that one instead of the default edition.
        next_appointment = @sorted_appointments.shift
        if next_appointment.nil?
          # no more scheduled editions, mark the start of the default edition and end
          @scheduled_times_hash[start_time] = @default_appointment
        else
          if next_appointment.start_time > start_time
            # the scheduled edition starts after start_time, fill the gap with the default edition
            @scheduled_times_hash[start_time] = @default_appointment
          end
          # start the next scheduled edition
          schedule_next(next_appointment.start_time, next_appointment)
        end
      else
        # mark the start of the current_appointment
        @scheduled_times_hash[start_time] = current_appointment

        # should we start the next edition or end the current one?
        if not @sorted_appointments.blank? and (current_appointment.end_time.nil? or @sorted_appointments.first.start_time < current_appointment.end_time)
          # next edition starts before current edition ends, push current onto stack and start the next edition
          next_appointment = @sorted_appointments.shift
          @appointments_stack.push(current_appointment)
          schedule_next(next_appointment.start_time, next_appointment)
        else
          # current edition ends or goes on forever
          unless current_appointment.end_time.nil?
            # edition ends before next edition, pop off the stack to find which edition to start next
            next_start_time = current_appointment.end_time

            # pop editions off the stack to find an edition that hasn't ended yet, may be nil (default edition)
            begin
              next_appointment = @appointments_stack.pop
            end while !next_appointment.nil? and !next_appointment.end_time.nil? and next_appointment.end_time <= next_start_time

            schedule_next(next_start_time, next_appointment)
          end
        end
      end
    end
  end
end
