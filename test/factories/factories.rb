Factory.define :plate do |p|
  p.sequence(:layout_name)  { |n| "layout_#{n}" }
  p.sequence(:plate_name)   { |n| "plate_#{n}" }
  p.instance_name           ''
  p.description             'Description'
end

Factory.define :plate_edition do |pe|
  pe.name         "Christmas edition"
  pe.association  :plate, :factory => :plate
end

Factory.define :published_plate_edition, :parent => :plate_edition do |pe|
  pe.name         "Current edition"
  pe.content      "<div><h1>Current content</h1></div>"
  pe.start_time   Time.zone.now
  pe.publish      true
end

Factory.define :default_plate_edition, :parent => :plate_edition do |pe|
  pe.name             "Default edition"
  pe.content          "<p>Default content</p>"
  pe.start_time       1.year.ago
  pe.end_time         1.year.ago + 1.day
  pe.publish          true
  pe.default_edition  true
end

Factory.define :past_published_plate_edition, :parent => :published_plate_edition do |pe|
  pe.name         "Past edition"
  pe.content      "<div>Past content</div>"
  pe.start_time   1.week.ago
  pe.end_time     1.day.ago
end

Factory.define :future_published_plate_edition, :parent => :published_plate_edition do |pe|
  pe.name         "Future edition"
  pe.content      "<p><i>Future content</i></p>"
  pe.start_time   1.week.from_now
  pe.end_time     2.weeks.from_now
end

Factory.define :event do |e|
  e.name        "Big sale event"
  e.start_time  Time.zone.now
  e.end_time    2.weeks.from_now
end

Factory.define :past_event do |e|
  e.name        "Man lands on the moon sale"
  e.start_time  1.week.ago
  e.end_time    1.day.ago
end

Factory.define :future_event do |e|
  e.name        "Man lands on mars sale"
  e.start_time  1.week.from_now
  e.end_time    2.weeks.from_now
end

Factory.define :plate_set do |ps|
  ps.name         "Collections layout"
  ps.layout_name  "collections"
end

Factory.define :plate_set_plate do |plate|
  plate.association             :plate_set, :factory => :plate_set
  plate.sequence(:plate_name)   { |n| "plate_#{n}" }
end
