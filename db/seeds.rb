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
  sports = Sport.create([{name: 'American Football'}, {name: 'Badminton'}, {name: 'Baseball'}, {name: 'Basketball'}, {name: 'Bowling'},
                         {name: 'Cricket'}, {name: 'Field Hockey'}, {name: 'Golf'}, {name: 'Handball'}, {name: 'Ice Hockey'},
                         {name: 'Lacrosse'},  {name: 'Pickleball'},  {name: 'Rugby'},  {name: 'Soccer'},  {name: 'Table Tennis'},
                         {name: 'Tennis'},  {name: 'Volleyball'}])
end

if EventType.count == 0
  EventType.create([{name: 'Class'}, {name: 'Exposition'}, {name: 'Fundraiser'}, {name: 'Meeting'},
                    {name: 'Reunion'}, {name: 'Tradeshow'}, {name: 'Training'}, {name: 'Tournament'},
                    {name: 'Workshop'}])
end

if AttendeeType.count == 0
  AttendeeType.create([{name: 'Advertiser'}, {name: 'Coach'}, {name: 'Exhibitor'}, {name: 'Instructor'},
                    {name: 'Media'}, {name: 'Official'}, {name: 'Player'}, {name: 'Staff'}, {name: 'Spectator'},
                       {name: 'Sponsor'}, {name: 'VIP'}])
end

if AgendaType.count == 0
  AgendaType.create([{name: 'Class'}, {name: 'Competition'}, {name: 'Social'}, {name: 'Sport'},
                       {name: 'VIP Event'}, {name: 'Workshop'}])
end
if Region.count == 0
  Region.create([{name: 'Atlantic', base: 'State', territoy: 'Massachusetts, Maine, New Hampshire, New York, Rhode Island, Vermont'},
                 {name: 'Atlantic South', base: 'Both', territoy: 'Alabama, Florida, Georgia, Mississippi, Puerto Rico'},
                 {name: 'Canada', base: 'Country', territoy: 'Canada'},{name: 'Great Lakes', base: 'State', territoy: 'Indiana, Michigan, Ohio, Ontario'},
                 {name: 'Great Plains', base: 'State', territoy: 'Colorado, Kansas, Montana, North Dakota, Nebraska, South Dakota, Wyoming'},
                 {name: 'Italy', base: 'Country', territoy: 'Italy'},
                 {name: 'LATAM', base: 'Country', territoy: 'Mexico, Argentina, Colombia, Costa Rica, Brazil'},
                 {name: 'Mid Atlantic', base: 'State', territoy: 'District of Columbia, Delaware, Kentucky, Maryland, North Carolina, New Jersey, Pennsylvania, South Carolina, Tennessee, Virginia, West Virginia'},
                 {name: 'Middle States', base: 'State', territoy: 'Illinois, WisconsinIowa, Missouri, Minnesota'},
                 {name: 'Mid South', base: 'State', territoy: 'Arkansas, Louisiana, Oklahoma, Texas'},
                 {name: 'Mountain', base: 'State', territoy: 'Utah, Nevada'},{name: 'Netherlands', base: 'Country', territoy: 'Netherlands'},
                 {name: 'Pacific Northwest', base: 'State', territoy: 'Alaska, Idaho, Oregon, Washington, British Columbia, Alberta'},
                 {name: 'South West', base: 'State', territoy: 'Arizona, New Mexico, Costa Rica, Mexico'},
                 {name: 'Spain', base: 'Country', territoy: 'Spain'},{name: 'West', base: 'State', territoy: 'California, Hawaii'}])
end

if Language.count == 0
  Language.create([{name: 'English', locale: 'en'}])
end
