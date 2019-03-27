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
                       {name: 'Sponsor'}, {name: 'VIP'}, {name: 'Director'}])
end

if AgendaType.count == 0
  AgendaType.create([{name: 'Clinic'}, {name: 'Competition', enabled:true}, {name: 'Social'}, {name: 'Exhibition/Tradeshow'}])
end
if Region.count == 0
  Region.create([{name: 'Atlantic', base: 'USA', territory: 'New York, Vermont, New Hampshire, Massachusetts, Rhode Island, Connecticut'},
                 {name: 'Mid-Atlantic', base: 'USA', territory: 'Pennsylvania, New Jersey, Delaware, Maryland, West Virginia, Kentucky, Tennessee, South Carolina, North Carolina'},
                 {name: 'Great Lakes', base: 'USA', territory: 'Ohio, Indiana, Michigan'},
                 {name: 'Atlantic-South', base: 'USA', territory: 'Mississippi, Georgia, Alabama, Florida'},
                 {name: 'Mid-South', base: 'USA', territory: 'Texas, Louisiana, Arkansas, Oklahoma'},
                 {name: 'Southwest', base: 'USA', territory: 'Arizona and New Mexico'},
                 {name: 'Mountain', base: 'USA', territory: 'Nevada, Utah'},
                 {name: 'West', base: 'USA', territory: 'California, Hawaii'},
                 {name: 'Pacific Northwest', base: 'USA', territory: 'Washington, Oregon, Idaho'},
                 {name: 'Great Plains', base: 'USA', territory: 'Montana, Wyoming, Colorado, North Dakota, South Dakota, Nebraska and Kansas'},
                 {name: 'Middle States', base: 'USA', territory: 'Minnesota, Iowa, Missouri, Wisconsin, Illinois'},
                ])
end

if Language.count == 0
  Language.create([{name: 'English', locale: 'en'}])
end

if Category.count == 0
  Category.create([{name: "Men's Singles"},{name: "Men's doubles"},{name: "Women's Singles"}, {name: "Women's doubles"}, {name: 'Mixed Doubles'}])
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
  SportRegulator.create([{name: 'International Federation of Pickleball / USA Pickleball Association rules', index: 0},{name: 'National Senior Games Association rules', index: 1, allow_age_range: true}])
end

if EliminationFormat.count == 0
  EliminationFormat.create!([{name: 'Single Elimination', index: 0, slug: 'single'},{name: 'Double Elimination', index: 1, slug: 'double'}, {name: 'Round Robin Elimination', index: 2, slug: 'round_robin'}])
end


if BusinessCategory.count == 0
  BusinessCategory.create([{code: "47",group:"corp, fin",description:"Accounting"},
                           {code: "94",group:"man, tech, tran",description:"Airlines/Aviation"},
                           {code: "120",group:"leg, org",description:"Alternative Dispute Resolution"},
                           {code: "125",group:"hlth",description:"Alternative Medicine"},
                           {code: "127",group:"art, med",description:"Animation"},
                           {code: "19",group:"good",description:"Apparel & Fashion"},
                           {code: "50",group:"cons",description:"Architecture & Planning"},
                           {code: "111",group:"art, med, rec",description:"Arts and Crafts"},
                           {code: "53",group:"man",description:"Automotive"},
                           {code: "52",group:"gov, man",description:"Aviation & Aerospace"},
                           {code: "41",group:"fin",description:"Banking"},
                           {code: "12",group:"gov, hlth, tech",description:"Biotechnology"},
                           {code: "36",group:"med, rec",description:"Broadcast Media"},
                           {code: "49",group:"cons",description:"Building Materials"},
                           {code: "138",group:"corp, man",description:"Business Supplies and Equipment"},
                           {code: "129",group:"fin",description:"Capital Markets"},
                           {code: "54",group:"man",description:"Chemicals"},
                           {code: "90",group:"org, serv",description:"Civic & Social Organization"},
                           {code: "51",group:"cons, gov",description:"Civil Engineering"},
                           {code: "128",group:"cons, corp, fin",description:"Commercial Real Estate"},
                           {code: "118",group:"tech",description:"Computer & Network Security"},
                           {code: "109",group:"med, rec",description:"Computer Games"},
                           {code: "3",group:"tech",description:"Computer Hardware"},
                           {code: "5",group:"tech",description:"Computer Networking"},
                           {code: "4",group:"tech",description:"Computer Software"},
                           {code: "48",group:"cons",description:"Construction"},
                           {code: "24",group:"good, man",description:"Consumer Electronics"},
                           {code: "25",group:"good, man",description:"Consumer Goods"},
                           {code: "91",group:"org, serv",description:"Consumer Services"},
                           {code: "18",group:"good",description:"Cosmetics"},
                           {code: "65",group:"agr",description:"Dairy"},
                           {code: "1",group:"gov, tech",description:"Defense & Space"},
                           {code: "99",group:"art, med",description:"Design"},
                           {code: "69",group:"edu",description:"Education Management"},
                           {code: "132",group:"edu, org",description:"E-Learning"},
                           {code: "112",group:"good, man",description:"Electrical/Electronic Manufacturing"},
                           {code: "28",group:"med, rec",description:"Entertainment"},
                           {code: "86",group:"org, serv",description:"Environmental Services"},
                           {code: "110",group:"corp, rec, serv",description:"Events Services"},
                           {code: "76",group:"gov",description:"Executive Office"},
                           {code: "122",group:"corp, serv",description:"Facilities Services"},
                           {code: "63",group:"agr",description:"Farming"},
                           {code: "43",group:"fin",description:"Financial Services"},
                           {code: "38",group:"art, med, rec",description:"Fine Art"},
                           {code: "66",group:"agr",description:"Fishery"},
                           {code: "34",group:"rec, serv",description:"Food & Beverages"},
                           {code: "23",group:"good, man, serv",description:"Food Production"},
                           {code: "101",group:"org",description:"Fund-Raising"},
                           {code: "26",group:"good, man",description:"Furniture"},
                           {code: "29",group:"rec",description:"Gambling & Casinos"},
                           {code: "145",group:"cons, man",description:"Glass, Ceramics & Concrete"},
                           {code: "75",group:"gov",description:"Government Administration"},
                           {code: "148",group:"gov",description:"Government Relations"},
                           {code: "140",group:"art, med",description:"Graphic Design"},
                           {code: "124",group:"hlth, rec",description:"Health, Wellness and Fitness"},
                           {code: "68",group:"edu",description:"Higher Education"},
                           {code: "14",group:"hlth",description:"Hospital & Health Care"},
                           {code: "31",group:"rec, serv, tran",description:"Hospitality"},
                           {code: "137",group:"corp",description:"Human Resources"},
                           {code: "134",group:"corp, good, tran",description:"Import and Export"},
                           {code: "88",group:"org, serv",description:"Individual & Family Services"},
                           {code: "147",group:"cons, man",description:"Industrial Automation"},
                           {code: "84",group:"med, serv",description:"Information Services"},
                           {code: "96",group:"tech",description:"Information Technology and Services"},
                           {code: "42",group:"fin",description:"Insurance"},
                           {code: "74",group:"gov",description:"International Affairs"},
                           {code: "141",group:"gov, org, tran",description:"International Trade and Development"},
                           {code: "6",group:"tech",description:"Internet"},
                           {code: "45",group:"fin",description:"Investment Banking"},
                           {code: "46",group:"fin",description:"Investment Management"},
                           {code: "73",group:"gov, leg",description:"Judiciary"},
                           {code: "77",group:"gov, leg",description:"Law Enforcement"},
                           {code: "9",group:"leg",description:"Law Practice"},
                           {code: "10",group:"leg",description:"Legal Services"},
                           {code: "72",group:"gov, leg",description:"Legislative Office"},
                           {code: "30",group:"rec, serv, tran",description:"Leisure, Travel & Tourism"},
                           {code: "85",group:"med, rec, serv",description:"Libraries"},
                           {code: "116",group:"corp, tran",description:"Logistics and Supply Chain"},
                           {code: "143",group:"good",description:"Luxury Goods & Jewelry"},
                           {code: "55",group:"man",description:"Machinery"},
                           {code: "11",group:"corp",description:"Management Consulting"},
                           {code: "95",group:"tran",description:"Maritime"},
                           {code: "97",group:"corp",description:"Market Research"},
                           {code: "80",group:"corp, med",description:"Marketing and Advertising"},
                           {code: "135",group:"cons, gov, man",description:"Mechanical or Industrial Engineering"},
                           {code: "126",group:"med, rec",description:"Media Production"},
                           {code: "17",group:"hlth",description:"Medical Devices"},
                           {code: "13",group:"hlth",description:"Medical Practice"},
                           {code: "139",group:"hlth",description:"Mental Health Care"},
                           {code: "71",group:"gov",description:"Military"},
                           {code: "56",group:"man",description:"Mining & Metals"},
                           {code: "35",group:"art, med, rec",description:"Motion Pictures and Film"},
                           {code: "37",group:"art, med, rec",description:"Museums and Institutions"},
                           {code: "115",group:"art, rec",description:"Music"},
                           {code: "114",group:"gov, man, tech",description:"Nanotechnology"},
                           {code: "81",group:"med, rec",description:"Newspapers"},
                           {code: "100",group:"org",description:"Non-Profit Organization Management"},
                           {code: "57",group:"man",description:"Oil & Energy"},
                           {code: "113",group:"med",description:"Online Media"},
                           {code: "123",group:"corp",description:"Outsourcing/Offshoring"},
                           {code: "87",group:"serv, tran",description:"Package/Freight Delivery"},
                           {code: "146",group:"good, man",description:"Packaging and Containers"},
                           {code: "61",group:"man",description:"Paper & Forest Products"},
                           {code: "39",group:"art, med, rec",description:"Performing Arts"},
                           {code: "15",group:"hlth, tech",description:"Pharmaceuticals"},
                           {code: "131",group:"org",description:"Philanthropy"},
                           {code: "136",group:"art, med, rec",description:"Photography"},
                           {code: "117",group:"man",description:"Plastics"},
                           {code: "107",group:"gov, org",description:"Political Organization"},
                           {code: "67",group:"edu",description:"Primary/Secondary Education"},
                           {code: "83",group:"med, rec",description:"Printing"},
                           {code: "105",group:"corp",description:"Professional Training & Coaching"},
                           {code: "102",group:"corp, org",description:"Program Development"},
                           {code: "79",group:"gov",description:"Public Policy"},
                           {code: "98",group:"corp",description:"Public Relations and Communications"},
                           {code: "78",group:"gov",description:"Public Safety"},
                           {code: "82",group:"med, rec",description:"Publishing"},
                           {code: "62",group:"man",description:"Railroad Manufacture"},
                           {code: "64",group:"agr",description:"Ranching"},
                           {code: "44",group:"cons, fin, good",description:"Real Estate"},
                           {code: "40",group:"rec, serv",description:"Recreational Facilities and Services"},
                           {code: "89",group:"org, serv",description:"Religious Institutions"},
                           {code: "144",group:"gov, man, org",description:"Renewables & Environment"},
                           {code: "70",group:"edu, gov",description:"Research"},
                           {code: "32",group:"rec, serv",description:"Restaurants"},
                           {code: "27",group:"good, man",description:"Retail"},
                           {code: "121",group:"corp, org, serv",description:"Security and Investigations"},
                           {code: "7",group:"tech",description:"Semiconductors"},
                           {code: "58",group:"man",description:"Shipbuilding"},
                           {code: "20",group:"good, rec",description:"Sporting Goods"},
                           {code: "33",group:"rec",description:"Sports"},
                           {code: "104",group:"corp",description:"Staffing and Recruiting"},
                           {code: "22",group:"good",description:"Supermarkets"},
                           {code: "8",group:"gov, tech",description:"Telecommunications"},
                           {code: "60",group:"man",description:"Textiles"},
                           {code: "130",group:"gov, org",description:"Think Tanks"},
                           {code: "21",group:"good",description:"Tobacco"},
                           {code: "108",group:"corp, gov, serv",description:"Translation and Localization"},
                           {code: "92",group:"tran",description:"Transportation/Trucking/Railroad"},
                           {code: "59",group:"man",description:"Utilities"},
                           {code: "106",group:"fin, tech",description:"Venture Capital & Private Equity"},
                           {code: "16",group:"hlth",description:"Veterinary"},
                           {code: "93",group:"tran",description:"Warehousing"},
                           {code: "133",group:"good",description:"Wholesale"},
                           {code: "142",group:"good, man, rec",description:"Wine and Spirits"},
                           {code: "119",group:"tech",description:"Wireless"},
                           {code: "103",group:"art, med, rec",description:"Writing and Editing"}])
end

if ProcessingFee.count == 0
  ProcessingFee.create([{title: 'Pass 100% of platform fee to registrants', amount_director: 0, amount_registrant: 100}, {title: 'Director pays registration fee', amount_director: 100, amount_registrant: 0}])
end
