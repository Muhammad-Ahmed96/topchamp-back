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

  desc 'Import brackets'
  task brackest_import: :environment do
    EventBracketAge.all.each do |bracket|
      data = {event_id:bracket[:event_id],:event_bracket_id => bracket[:event_bracket_skill_id], :age => bracket[:age],
              :quantity => bracket[:quantity]}
      EventBracket.create!(data)
    end

    EventBracket.where(:event_id => nil).all.each do |bracket|
      if bracket.event_bracket_id.present?
        skill = EventBracketSkill.where(:id => bracket[:event_bracket_id]).first
        bracket.event_id = skill.event_id;
        bracket.save!
      end
    end

    EventBracketSkill.all.each do |bracket|
      data = {event_id:bracket[:event_id], :event_bracket_id => bracket[:event_bracket_age_id],:lowest_skill => bracket[:lowest_skill],
              :highest_skill => bracket[:highest_skill], :quantity => bracket[:quantity]}
      EventBracket.create!(data)
    end

    EventBracket.where(:event_id => nil).all.each do |bracket|
      if bracket.event_bracket_id.present?
        skill = EventBracketAge.where(:id => bracket[:event_bracket_id]).first
        bracket.event_id = skill.event_id;
        bracket.save!
      end
    end

    EventBracket.where.not(:event_bracket_id => nil).all.each do |bracket|
      if bracket.event_bracket_id.present?
        skill = EventBracketSkill.where(:id => bracket[:event_bracket_id]).first
        if skill.present?
          my = EventBracket.where(:lowest_skill => skill.lowest_skill).where(:quantity => skill.quantity)
                   .where(:highest_skill => skill.highest_skill).where(:event_id => skill.event_id)
          bracket.event_bracket_id = my.first.id;
          bracket.save!
        end
        age = EventBracketAge.where(:id => bracket[:event_bracket_id]).first
        if age.present?
          my = EventBracket.where(:age => age.age).where(:quantity => age.quantity).where(:event_id => age.event_id)
          bracket.event_bracket_id = my.first.id;
          bracket.save!
        end

      end
    end
  end


  desc 'Ceate director participants'
  task create_directors: :environment do
    Event.all.each do |event|
      types = [AttendeeType.director_id]
      participant = Participant.where(:user_id => event.creator_user_id).where(:event_id => event.id).first_or_create!
      types |= participant.attendee_type_ids.to_a
      participant.attendee_type_ids = types
    end
  end

  desc 'Set team count'
  task tournament_teams_count: :environment do
    Tournament.all.each do |tournament|
      tournament.set_team_count
      tournament.set_matches_status
    end
  end


  desc 'Send notification reminder'
  task event_reminder: :environment do
   events = Event.where(:start_date => 5.days.from_now).all
   events.each do |event|
     event.send_notification
   end
  end



end