class CreatePlates < ActiveRecord::Migration
  def self.up
    create_table :plates do |t|
      t.string  "layout_name"
      t.string  "instance_name"
      t.string  "plate_name"
      t.text    "description"
      
      t.timestamps
    end
  end

  def self.down
    drop_table :plates
  end
end
