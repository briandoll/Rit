class UniqueIndexOnPlateEditions < ActiveRecord::Migration
  def self.up
    add_index :plate_editions, [:plate_id, :event_id], :unique => true
  end

  def self.down
    remove_index :plate_editions, :column => [:plate_id, :event_id]
  end
end
