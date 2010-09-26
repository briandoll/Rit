Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.define :user do |user|
  user.email                 { Factory.next :email }
  user.password              { "password" }
  user.password_confirmation { "password" }
  user.active                { true }
end

Factory.define :email_confirmed_user, :parent => :user do |user|
  user.email_confirmed { true }
end

Factory.define :inactive_user, :parent => :email_confirmed_user do |user|
  user.active { false }
end

Factory.define :admin_user, :parent => :email_confirmed_user do |user|
  user.admin  { true }
end
