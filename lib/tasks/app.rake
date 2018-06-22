namespace :app do

  desc 'Tail remote log files'
  task remote_logs: :environment do
    logfile = ENV['LOG'] || fetch(:rails_env)
    execute %(tail -n0 -F #{shared_path}/log/#{logfile}.log | while read line; do echo "$(hostname): $line"; done)
  end


  desc 'Add users ids'
  task users_id: :environment do
    User.where(:membership_id => nil).all.each do |user|
      if user.membership_id.nil?
        user.set_random_membership_id!
        user.save!
      end
    end
  end

end