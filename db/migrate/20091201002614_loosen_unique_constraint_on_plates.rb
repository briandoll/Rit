class LoosenUniqueConstraintOnPlates < ActiveRecord::Migration
  def self.up
    remove_index :plates, :column => [:layout_name, :plate_name]
    add_index :plates, [:layout_name, :instance_name, :plate_name], :unique => true
  end

  def self.down
    remove_index :plates, :column => [:layout_name, :plate_name]
    add_index :plates, [:layout_name, :plate_name], :unique => true
  end
end
