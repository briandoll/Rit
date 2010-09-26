# == Schema Information
#
# Table name: plate_editions
#
#  id              :integer         not null, primary key
#  plate_id        :integer
#  event_id        :integer
#  name            :string(255)
#  content         :text
#  description     :text
#  publish         :boolean         default(FALSE)
#  start_time      :datetime
#  end_time        :datetime
#  default_edition :boolean         default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_plate_editions_on_plate_id_and_event_id  (plate_id,event_id) UNIQUE
#

class PlateEdition < ActiveRecord::Base
  belongs_to :plate
  belongs_to :event

  validates_presence_of :plate
  validates_presence_of :name
  validates_uniqueness_of :plate_id,
                          :scope => :event_id,
                          :if => :belongs_to_event?,
                          :message => "is already part of this Event.  Remove the other Edition first."
  validate  :default_edition_cannot_be_set_on_unpublished,
            :end_time_cannot_exist_without_start_time,
            :end_time_cannot_be_earlier_than_start_time,
            :publish_cannot_be_set_without_start_time

  before_save :set_times_to_event, :if => :belongs_to_event?
  after_save :clear_cache

  include StartsAndEndsByDateHour

  def belongs_to_event?
    not event_id.blank?
  end

  def start_time=(val)
    if belongs_to_event?
      raise ArgumentError, "Belongs to an event: #{event_id}"
    else
      super
    end
  end

  def end_time=(val)
    if belongs_to_event?
      raise ArgumentError, "Belongs to an event: #{event_id}"
    else
      super
    end
  end

  def update_attributes(attributes)
    self.event_id = attributes.fetch('event_id', nil)
    super
  end

  def active_times
    active = []
    all_start_times = plate.edition_start_times(nil)
    unless all_start_times.blank?
      sorted_times = all_start_times.keys.sort
      sorted_times.each_cons(2) do |current_start_time, current_end_time|
        edition = all_start_times[current_start_time]
        if !edition.nil? && edition.id == id
          active << [current_start_time, current_end_time]
        end
      end

      # does the last edition run on forever?
      last_edition = all_start_times[sorted_times.last]
      if !last_edition.nil? && last_edition.id == id
        active << [sorted_times.last, nil]
      end
    end
    active
  end

  def effective_start_times
    active_times.map { |t| t[0] }
  end

  def effective_end_times
    active_times.map { |t| t[1] }
  end

  def current_end_time(at_time = Time.zone.now)
    valid_times = active_times.find { |times| at_time >= times[0] and (times[1].nil? or at_time < times[1]) }
    if !valid_times.nil?
      valid_times[1]
    else
      raise IndexError, "Not active at this time"
    end
  end

  def conflicting_editions
    # TODO - does this need some caching?
    q = "plate_id = ? AND publish = ? AND id <> ?"
    args = [plate.id, true, id]
    unless end_time.nil?
      q << " AND start_time <= ?"
      args << end_time
    end
    q << " AND (end_time > ? OR end_time IS NULL)"
    args << start_time

    edition = PlateEdition.find(:all, :conditions => [q, *args])
  end

  def conflicting_editions?
    !conflicting_editions.blank?
  end

  def live?
    plate.edition_now == self
  end

  private

  def default_edition_cannot_be_set_on_unpublished
      errors.add('default_edition', "can't be set if not published") if (default_edition and not publish)
  end

  def end_time_cannot_exist_without_start_time
    errors.add('end_time', "can't be set without start_time") if (not end_time.nil? and start_time.nil?)
  end

  def end_time_cannot_be_earlier_than_start_time
    unless end_time.nil? or start_time.nil?
      errors.add('end_time', "can't be earlier than start_time") if end_time < start_time
    end
  end

  def publish_cannot_be_set_without_start_time
    # Can't publish without a start time, unless it's part of an event (start_time is added in the
    # after_save so there's no need to validate it here)
    if publish and start_time.nil? and event_id.nil?
      errors.add('publish', "can't be set without a start_time")
    end
  end

  def set_times_to_event
    self[:start_time] = event.start_time
    self[:end_time] = event.end_time
  end

  def clear_cache
    Rails.cache.clear
  end
end
