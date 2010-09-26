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

class Plate < ActiveRecord::Base
  has_many :plate_editions, :dependent => :destroy
  has_one :default_plate_edition, :class_name => "PlateEdition", :conditions => {:publish => true, :default_edition => true}
  has_many :events, :through => :plate_editions

  validates_presence_of :layout_name, :plate_name
  validates_uniqueness_of :plate_name, :scope => [:layout_name, :instance_name]
  validates_format_of :layout_name, :with => /^[a-zA-Z0-9\-_.]*$/
  validates_format_of :instance_name, :with => /^[a-zA-Z0-9\-_.]*$/
  validates_format_of :plate_name, :with => /^[a-zA-Z0-9\-_.]*$/

  after_save :clear_cache

  # The first year SMP took orders
  BEGINNING_OF_TIME = Time.zone.local(1998, 1, 1)

  class << self
    def all_cached
      Rails.cache.fetch('Plate.all') { all }
    end
  end

  def edition_on(date)
    # SQL version:
    # edition = PlateEdition.find(:first, :conditions => [
    #   "plate_id = ? AND publish = ? AND start_time <= ? AND (end_time > ? OR end_time IS NULL)", id, true, date, date ],
    #   :order => "start_time DESC, updated_at DESC")

    edition = nil
    # get full edition timeline
    start_times = edition_start_times(nil)
    start_time = start_times.keys.sort.reverse.find { |t| t <= date }
    unless start_time.nil?  || start_times[start_time].nil?
      if start_times[start_time].end_time.nil? or start_times[start_time].end_time > date
        edition = start_times[start_time]
      end
    end
    edition.nil? ? default_plate_edition : edition
  end

  def edition_now
    edition_on(Time.zone.now)
  end

  # Returns a hash of start times and plate editions
  # starting_from can be null, a TimeWithZone, or :now.  null returns a hash that starts with the
  # the BEGINNING_OF_TIME.
  def edition_start_times(starting_from = :now)
    # TODO - Ugly solution to loading the class for Marshal in development mode.  Marshal!
    PlateEdition
    Event

    if starting_from == :now
      starting_from = Time.zone.now
      Rails.cache.fetch(edition_start_times_key, :expires_in => 1.hour) do
        calculate_edition_start_times(starting_from)
      end
    elsif starting_from.nil?
      Rails.cache.fetch(edition_start_times_key + '/all') do
        calculate_edition_start_times(starting_from)
      end
    else
      calculate_edition_start_times(starting_from)
    end
  end

  def clear_edition_start_times_cache
    Rails.cache.delete(edition_start_times_key)
    Rails.cache.delete(edition_start_times_key + '/all')
  end

  private

  def clear_cache
    Rails.cache.delete('Plate.all')
  end

  def edition_start_times_key
    "plate/#{id}/edition_start_times"
  end

  # Returns a hash of start times and plate edition tuples.
  # The timeline will start from starting_from.  If starting_from is nil, then the timeline will start
  # from the BEGINNING_OF_TIME.
  def calculate_edition_start_times(starting_from=nil)
    if starting_from.nil?
      starting_from = BEGINNING_OF_TIME
    end

    editions = plate_editions.find_all { |e|  (e.end_time.nil? or e.end_time > starting_from) and e.publish and (e.event.nil? or e.event.publish) }

    # sort by start_time, updated_at
    editions.sort! do |a, b|
      if a.start_time == b.start_time
        a.updated_at <=> b.updated_at
      else
        a.start_time <=> b.start_time
      end
    end
    editions_by_start_time = Scheduler.timeline(editions, default_plate_edition)
    # start with default edition if we need to
    if editions_by_start_time.blank? or starting_from < editions_by_start_time.keys.sort.first
      editions_by_start_time[starting_from] = default_plate_edition unless default_plate_edition.nil?
    end
    start_times = {}
    editions_by_start_time.select { |k, v| k >= starting_from }.each { |k, v| start_times[k] = v }
    start_times
  end
end
