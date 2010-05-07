class Event < ActiveRecord::Base
  has_many :plate_editions
  has_many :plates, :through => :plate_editions

  validates_presence_of :name, :start_time, :end_time
  validate  :end_time_cannot_be_earlier_than_start_time

  after_save :set_plate_edition_times, :clear_cache

  include StartsAndEndsByDateHour

  class << self
    def all_cached
      Rails.cache.fetch('Event.all') { all }
    end
    
    def all_preview_json
      events = {}
      all_cached.each do |e|
        events[e.id] = {  'name'       => e.name,
                          'start_date' => e.start_time.strftime(Rit::Config.date_format),
                          'start_hour' => e.start_time.hour,
                          'end_date'   => e.end_time.strftime(Rit::Config.date_format),
                          'end_hour'   => e.end_time.hour }
      end
      events.to_json
    end
  end

  def publish?
    publish == true
  end

  def live?
    now = Time.zone.now
    (now > start_time and now < end_time) and publish?
  end


  private

  def end_time_cannot_be_earlier_than_start_time
    unless end_time.nil? or start_time.nil?
      errors.add('end_time', "can't be earlier than start_time") if end_time < start_time
    end
  end

  def set_plate_edition_times
    plate_editions.each do |pe|
      pe.save
    end
  end

  def clear_cache
    Rails.cache.delete('Event.all')
  end
end