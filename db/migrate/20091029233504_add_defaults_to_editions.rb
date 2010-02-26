class AddDefaultsToEditions < ActiveRecord::Migration
  def self.up
    change_column :plate_editions, :publish, :boolean, :default => false
    rename_column :plate_editions, :default, :default_edition
    change_column :plate_editions, :default_edition, :boolean, :default => false
  end

  def self.down
    change_column :plate_editions, :publish, :boolean, :default => nil
    change_column :plate_editions, :default_edition, :boolean, :default => nil
    rename_column :plate_editions, :default_edition, :default
  end
end
