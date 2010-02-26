class UniqueIndexOnPlates < ActiveRecord::Migration
  def self.up
    add_index :plates, [:layout_name, :plate_name], :unique => true
  end

  def self.down
    remove_index :plates, :column => [:layout_name, :plate_name]
  end
end
