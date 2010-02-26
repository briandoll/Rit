class CreatePlateSetPlateNames < ActiveRecord::Migration
  def self.up
    create_table :plate_set_plate_names do |t|
      t.integer     "plate_set_id"
      t.string      "plate_name"
      t.string      "description"
      t.timestamps
    end
  end

  def self.down
    drop_table :plate_set_plate_names
  end
end
