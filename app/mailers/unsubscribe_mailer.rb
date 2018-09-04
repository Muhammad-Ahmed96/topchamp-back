class UnsubscribeMailer < ApplicationMailer
  def unsubscribe(bracket, category, director, registrant, event)
    @bracket = bracket
    @category = category
    @director = director
    @registrant = registrant
    @bracket_description = ""

    case event.bracket_by
    when "age"
      if @bracket.age.present?
        @bracket_description = "Age: #{@bracket.age}"
      else
        @bracket_description = "Young age: #{@bracket.young_age}, Old age: #{@bracket.old_age}"
      end
    when "skill"
      @bracket_description = "Lowest skill: #{@bracket.lowest_skill}, Highest skill: #{@bracket.highest_skill}"
    when "skill_age"
     main_bracket =  @bracket.brackets.where(:id => @bracket.event_bracket_id).first
     if main_bracket.nil?
       main_bracket = @bracket
     end
      if @bracket.age.present?
        age = "Age: #{@bracket.age}"
      else
        age = "Young age: #{@bracket.young_age}, Old age: #{@bracket.old_age}"
      end
      @bracket_description = "Lowest skill: #{main_bracket.lowest_skill}, Highest skill: #{main_bracket.highest_skill} [#{age}]"
    when "age_skill"
      main_bracket =  @bracket.brackets.where(:id => @bracket.event_bracket_id).first
      if main_bracket.nil?
        main_bracket = @bracket
      end
      skill = "Lowest skill: #{@bracket.lowest_skill}, Highest skill: #{@bracket.highest_skill}"
      if @bracket.age.present?
        @bracket_description = "Age: #{main_bracket.age} [#{skill}]"
      else
        @bracket_description = "Young age: #{main_bracket.young_age}, Old age: #{main_bracket.old_age} [#{skill}]"
      end
    end
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    mail(to: director.email, subject: "Registry cancellation")
  end


  def spot_open(user, event, url)
    @event = event
    @user = user
    @url = url
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    mail(to: user.email, subject: "New spot open!")
  end
end
