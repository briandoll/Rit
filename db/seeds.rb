# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

if Rails.env.eql?('development')
  #
  # Plates
  #
  plate = Plate.create(
    :layout_name => "plated-layout",
    :instance_name => "",
    :plate_name => "main-content",
    :description => "A *Plate* is a class of content. A plate is identified by the combination of it's *Layout Name*, *Instance Name* and *Plate Name*. The names are used to classify and organize plates."
  )

  # TODO: seeds.rb add examples of Plate and instance names

  #
  # Events
  #
  # TODO: seeds.rb add examples of various Events

  #
  # Users
  #
  admin = User.create!(:email => "admin@example.com", :password => "admin", :admin => true)
  admin.confirm_email!

  user = User.create!(:email => "user@example.com", :password => "user")
  user.confirm_email!

  #
  # Plate Sets
  #
  plate_set = PlateSet.create(
    :name => "blueprint-plate-set",
    :layout_name => "blueprint-layout",
    :description => "A *Plate Set* is a template for generating a group of related *Plates*. For example, if a help page has a body plate and a left column plate, a user can generate an instance of both those plates from that plate set."
  )
  PlateSetPlate.create(
    :plate_name => "blueprint-header",
    :description => "blueprint's header plate",
    :plate_set => plate_set
  )
  PlateSetPlate.create(
    :plate_name => "blueprint-footer",
    :description => "blueprint's footer plate",
    :plate_set => plate_set
  )
  # FIXME: seeds.rb plate_set is not creating plates?
  # plate_set.create_plates("blueprint", "Created from 'blueprint-plate-set")
end
