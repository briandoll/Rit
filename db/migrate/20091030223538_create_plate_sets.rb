class CreatePlateSets < ActiveRecord::Migration
  def self.up
    create_table :plate_sets do |t|
      t.string      "name"
      t.string      "description"
      t.string      "layout_name"
      
      t.timestamps
    end
  end

  def self.down
    drop_table :plate_sets
  end
end
