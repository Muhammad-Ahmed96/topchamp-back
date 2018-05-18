namespace :top_champ do
  desc "Create users"
  task CreateUsers: :environment do
    70.times do
      user = User.new(:email => Faker::Internet.unique.email, :password => 'password', :password_confirmation => 'password',
                      :first_name => Faker::Name.unique.first_name, :middle_initial => 'M', :last_name=>Faker::Name.unique.last_name,
                      :gender => :Male, :role => :Sysadmin, :badge_name => Faker::Name.name,
                      :birth_date => Faker::Date.birthday(18, 65))
      user.confirm
      user.save!
    end
  end

end
