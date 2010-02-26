class RenamePlateSetPlates < ActiveRecord::Migration
  def self.up
    rename_table :plate_set_plate_names, :plate_set_plates
  end

  def self.down
    rename_table :plate_set_plates, :plate_set_plate_names
  end
end
