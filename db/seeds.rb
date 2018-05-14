# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.find_by_uid('user@email.com')
if user.nil?
  user = User.new(:email => 'user@email.com', :password => 'password', :password_confirmation => 'password',
                  :first_name => 'first_name', :middle_initial => 'm', :last_name=>'last_name',
                  :gender => :Male, :role => :Sysadmin, :badge_name => 'badge_name',
                  :birth_date => '2000-01-01')
  user.confirm
  user.save!
end

user = User.find_by_uid('test@yopmail.com')
if user.nil?
  user = User.new(:email => 'test@yopmail.com', :password => 'password', :password_confirmation => 'password',
                  :first_name => 'first name', :middle_initial => 'm', :last_name=>'last name',
                  :gender => :Male, :role => :Sysadmin, :badge_name => 'badge_name',
                  :birth_date => '2000-01-01')
  user.confirm
  user.save!
end
if Sport.count == 0
  sports = Sport.create([{name: 'Pickleball'}, {name: 'Football Soccer'}])
end

if EventType.count == 0
  EventType.create([{name: 'Class'}, {name: 'Exposition'}, {name: 'Fundraiser'}, {name: 'Meeting'},
                    {name: 'Reunion'}, {name: 'Tradeshow'}, {name: 'Training'}, {name: 'Tournament'},
                    {name: 'Workshop'}])
end
