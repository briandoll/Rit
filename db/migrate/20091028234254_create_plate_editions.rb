class CreatePlateEditions < ActiveRecord::Migration
  def self.up
    create_table :plate_editions do |t|
      t.integer   "plate_id"
      t.integer   "event_id"
      t.string    "name"
      t.text      "content"
      t.text      "description"
      t.boolean   "publish"
      t.datetime  "start_time"
      t.datetime  "end_time"
      t.boolean   "default"
      
      t.timestamps
    end
  end

  def self.down
    drop_table :plate_editions
  end
end
