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
  Region.create([{name: 'Atlantic', base: 'State', territoy: 'Connecticut, Massachusetts, Maine, New Hampshire, New York, Rhode Island, Vermont'},
                 {name: 'Atlantic South', base: 'Both', territoy: 'Alabama, Florida, Georgia, Mississippi, Puerto Rico'},
                 {name: 'Canada', base: 'Country', territoy: 'Canada'},{name: 'Great Lakes', base: 'State', territoy: 'Indiana, Michigan, Ohio, Ontario'},
                 {name: 'Great Plains', base: 'State', territoy: 'Colorado, Kansas, Montana, North Dakota, Nebraska, South Dakota, Wyoming'},
                 {name: 'Italy', base: 'Country', territoy: 'Italy'},
                 {name: 'LATAM', base: 'Country', territoy: 'Mexico, Argentina, Colombia, Costa Rica, Brazil'},
                 {name: 'Mid Atlantic', base: 'State', territoy: 'District of Columbia, Delaware, Kentucky, Maryland, North Carolina, New Jersey, Pennsylvania, South Carolina, Tennessee, Virginia, West Virginia'},
                 {name: 'Middle States', base: 'State', territoy: 'Illinois, Wisconsin, Iowa, Missouri, Minnesota'},
                 {name: 'Mid South', base: 'State', territoy: 'Arkansas, Louisiana, Oklahoma, Texas'},
                 {name: 'Mountain', base: 'State', territoy: 'Utah, Nevada'},{name: 'Netherlands', base: 'Country', territoy: 'Netherlands'},
                 {name: 'Pacific Northwest', base: 'State', territoy: 'Alaska, Idaho, Oregon, Washington, British Columbia, Alberta'},
                 {name: 'South West', base: 'State', territoy: 'Arizona, New Mexico, Costa Rica, Mexico'},
                 {name: 'Spain', base: 'Country', territoy: 'Spain'},{name: 'West', base: 'State', territoy: 'California, Hawaii'}])
end

if Language.count == 0
  Language.create([{name: 'English', locale: 'en'}])
end

if Category.count == 0
  Category.create([{name: 'Men Singles'},{name: 'Men Double'},{name: 'Women Singles'}, {name: 'Women Double'}, {name: 'Mixed Double'}])
end

if ScoringOption.count == 0
  ScoringOption.create([{description: "2 of 3 games to 11 points win by 2 points (Match usually takes 54 min.)", quantity_games: 3, winner_games: 2,
                         points: 11, win_by: 2, duration: 54, index: 0},
                        {description: "1 of 1 game to 15 points win by 2 points (Match usually takes 32 min.)", quantity_games: 1, winner_games: 1,
                         points: 15, win_by: 2, duration: 32, index: 1},
                        {description: "1 of 1 game to 15 points win by 1 point (Match usually takes 32 min.)", quantity_games: 1, winner_games: 1,
                         points: 15, win_by: 1, duration: 32, index: 2},
                        {description: "1 of 1 game to 21 points win by 2 points (Match usually takes 45 min.)", quantity_games: 1, winner_games: 1,
                         points: 21, win_by: 2, duration: 45, index: 3},
                        {description: "1 of 1 game to 21 points win by 1 point (Match usually takes 45 min.)", quantity_games: 1, winner_games: 1,
                         points: 21, win_by: 1, duration: 45, index: 4}])
end

if SportRegulator.count == 0
  SportRegulator.create([{name: 'International Federation of Pickleball / USA Pickleball Association rules', index: 0},{name: 'National Senior Games Association rules', index: 1}])
end

if EliminationFormat.count == 0
  EliminationFormat.create!([{name: 'Single Elimination', index: 0},{name: 'Double Elimination', index: 1}, {name: 'Double Elimination', index: 2}, {name: 'Round Robin Elimination', index: 3},
                            {name: 'Pool Play Elimination', index: 4}])
end
