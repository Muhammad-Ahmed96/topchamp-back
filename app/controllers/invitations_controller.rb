class InvitationsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:update, :destroy, :resend_mail]
  around_action :transactions_filter, only: [:event, :date, :sing_up, :enroll, :partner]
  swagger_path '/invitations' do
    operation :get do
      key :summary, 'Get invitations list'
      key :description, 'Invitations'
      key :operationId, 'invitationsIndex'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :column
        key :in, :query
        key :description, 'Column to order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :direction
        key :in, :query
        key :description, 'Direction to order, (ASC or DESC)'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'Invitation Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Invitation
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', :PaginateModel
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def index
    column = params[:column].nil? ? 'email' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    email = params[:email]
    status = params[:status]
    phone = params[:phone]
    event = params[:event]
    first_name = params[:first_name]
    last_name = params[:last_name]
    eventColumn = nil
    userColumn = nil
    phoneColumn = nil
    if column.to_s == "event"
      eventColumn = "title"
      column = nil
    end

    if column.to_s == "first_name"
      userColumn = column
      column = nil
    end

    if column.to_s == "last_name"
      userColumn = column
      column = nil
    end

    if column.to_s == "phone"
      phoneColumn = "cell_phone"
      column = nil
    end

    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    invitations = InvitationPolicy::Scope.new(current_user, Invitation).resolve.my_order(column, direction).event_like(event)
                      .email_like(email).first_name_like(first_name).last_name_like(last_name).event_order(eventColumn, direction).user_order(userColumn, direction)
                      .in_status(status).phone_like(phone).phone_order(phoneColumn, direction)
    if paginate.to_s == "0"
      json_response_serializer_collection(invitations.all, InvitationSerializer)
    else
      paginate invitations, per_page: 50, root: :data
    end
  end


  swagger_path '/invitations/partners' do
    operation :get do
      key :summary, 'Get invitations partner list'
      key :description, 'Invitations'
      key :operationId, 'invitationsIndexPartner'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :column
        key :in, :query
        key :description, 'Column to order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :direction
        key :in, :query
        key :description, 'Direction to order, (ASC or DESC)'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :type
        key :in, :query
        key :description, "partner_mixed or partner_double"
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'Invitation Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Invitation
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', :PaginateModel
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def index_partner
    valid_types = ["partner_mixed", "partner_double"]
    column = params[:column].nil? ? 'email' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    email = params[:email]
    status = params[:status]
    phone = params[:phone]
    event = params[:event]
    first_name = params[:first_name]
    last_name = params[:last_name]
    type = params[:type].nil? ? valid_types : [params[:type]]
    event_id = index_partners_params

    invitatin_type = []

    unless type.included_in? valid_types
      return response_no_type
    end
    eventColumn = nil
    userColumn = nil
    phoneColumn = nil
    if column.to_s == "event"
      eventColumn = "title"
      column = nil
    end

    if column.to_s == "first_name"
      userColumn = column
      column = nil
    end

    if column.to_s == "last_name"
      userColumn = column
      column = nil
    end

    if column.to_s == "phone"
      phoneColumn = "cell_phone"
      column = nil
    end

    #check if category is paid
    # player = Player.where(user_id: @resource.id).where(event_id: event_id).first
    #  categories_ids = player.present? ? player.brackets.where.not(:payment_transaction_id => nil).distinct.pluck(:category_id) : []
    #  if categories_ids.included_in? Category.doubles_categories
    #    invitatin_type << "partner_double"
    #  end
    #
    #  if categories_ids.included_in? Category.mixed_categories
    #    invitatin_type << "partner_mixed"
    #  end
    #end check if category is paid
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    invitations = Invitation.my_order(column, direction).event_like(event)
                      .email_like(email).first_name_like(first_name).last_name_like(last_name).event_order(eventColumn, direction).user_order(userColumn, direction)
                      .in_status(status).phone_like(phone).phone_order(phoneColumn, direction).in_type(type).where(:user_id => @resource.id).where(:event_id => event_id)
                      .where(:status => "pending_confirmation").where(:invitation_type => type)
    if paginate.to_s == "0"
      json_response_serializer_collection(invitations.all, InvitationSerializer)
    else
      paginate invitations, per_page: 50, root: :data
    end
  end

  swagger_path '/invitations/event' do
    operation :post do
      key :summary, 'Invitations to event'
      key :description, 'Invitations Catalog'
      key :operationId, 'invitationsEventCreate'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :invitations
        key :in, :body
        key :description, 'Invitations'
        key :type, :array
        items do
          key :'$ref', :InvitationInput
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def event
    authorize Invitation
    if is_array_save?
      save_array :event
    else
      save :event
    end

  end

  swagger_path '/invitations/date' do
    operation :post do
      key :summary, 'Invitations to date'
      key :description, 'Invitations'
      key :operationId, 'invitationsDateCreate'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :invitations
        key :in, :body
        key :description, 'Invitations'
        key :type, :array
        items do
          key :'$ref', :InvitationInput
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def date
    authorize Invitation
    if is_array_save?
      save_array :date
    else
      save :date
    end
  end

  swagger_path '/invitations/sing_up' do
    operation :post do
      key :summary, 'Invitations to sing up'
      key :description, 'Invitations'
      key :operationId, 'invitationsSingUpCreate'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :invitations
        key :in, :body
        key :description, 'Invitations'
        key :type, :array
        items do
          key :'$ref', :InvitationInput
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def sing_up
    authorize Invitation
    if is_array_save?
      save_array :sing_up
    else
      save :sing_up
    end
  end

  swagger_path '/invitations/:id' do
    operation :get do
      key :summary, 'Invitations show details'
      key :description, 'Invitations'
      key :operationId, 'invitationsShow'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :Invitation
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def show
    @invitation = Invitation.find(params[:id])
    authorize Invitation
    json_response_serializer(@invitation, InvitationSerializer)
  end

  swagger_path '/invitations/:id/resend_mail' do
    operation :post do
      key :summary, 'Invitations resend mail'
      key :description, 'Invitations'
      key :operationId, 'invitationsResendMailCreate'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def resend_mail
    authorize Invitation
    @invitation.send_mail(true)
    json_response_success(t("mail_send", model: Invitation.model_name.human), true)
  end

  def update
    authorize Invitation
    json_response_success(t("edited_success", model: Invitation.model_name.human), true)
  end

  def destroy
    authorize Invitation
    @invitation.destroy
    json_response_success(t("deleted_success", model: Invitation.model_name.human), true)
  end


  def import_xls
    authorize Invitation
    Invitation.import_invitations_xls!(import_params[:file], import_params[:event_id], :event)
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/invitations/:id/enroll' do
    operation :post do
      key :summary, 'Invitations enroll'
      key :description, 'Invitations'
      key :operationId, 'invitationsEnrollCreate'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :attendee_types
        key :in, :body
        key :required, true
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def enroll
    @invitation = Invitation.find(params[:id])
    if @invitation.status != "accepted"
      event = @invitation.event
      for_validate_partner = false
      category_id = nil
      if event.present?
        if @invitation.invitation_type == "partner_mixed"
          category_id = Category.single_mixed_category
          for_validate_partner = true
        elsif @invitation.invitation_type == "partner_double"
          user = User.find(@invitation.user_id)
          if user.present?
            if user.gender == "Male"
              category_id = Category.single_men_double_category
            elsif user.gender == "Female"
              category_id = Category.single_women_double_category
            end
          end
          for_validate_partner = true
        end
        if for_validate_partner
          player = Player.where(user_id: @invitation.user_id).where(event_id: event.id).first
          if player.present?
            @invitation.brackets.where(:category_id => category_id).each do |item|
              if player.have_partner?(category_id, item.event_bracket_id)
                @invitation.status = "declined"
                @invitation.save!(:validate => false)
                return json_response_error([t("player.partner.validation.already_partner")], 422)
              end
            end
          else
            return json_response_error([t("player.partner.validation.invalid_inforamtion")], 422)
          end

          player_sender = Player.where(user_id: @invitation.sender_id).where(event_id: event.id).first
          if player_sender.present?
            @invitation.brackets.where(:category_id => category_id).each do |item|
              if player_sender.have_partner?(category_id, item.event_bracket_id)
                @invitation.status = "declined"
                @invitation.save!(:validate => false)
                return json_response_error([t("player.partner.validation.already_partner_sender")], 422)
              end
            end
          else
            return json_response_error([t("player.partner.validation.invalid_inforamtion")], 422)
          end
        end
        types = enroll_params[:attendee_types] #@invitation.attendee_type_ids
        if types.nil? or (!types.kind_of?(Array) or types.length <= 0)
          types = []
        end
        type_id = AttendeeType.player_id
        is_player = types.detect {|w| w == type_id}
        unless is_player.nil?
          #Create player
          types.delete(type_id)
          #player = Player.where(user_id: @invitation.user_id).where(event_id: event.id).first
        end
        if types.length > 0
          participant = Participant.where(:user_id => @invitation.user_id).where(:event_id => event.id).first_or_create!
          types = types + participant.attendee_type_ids.to_a
          participant.attendee_type_ids = types
        end
        @bracket_description = ""
        @invitation.status = :accepted
        @invitation.save!
        if @invitation.invitation_type == "partner_mixed" or @invitation.invitation_type == "partner_double"
          #ckeck partner brackets
          @invitation.brackets.where(:category_id => category_id).each do |item|
            bracket = item.bracket
            type = nil
            result = Player.validate_partner( @invitation.user_id, @invitation.sender_id,item.event_bracket_id, category_id)
            if result == true
              players = []
              player1 = Player.where(user_id: @invitation.user_id).where(event_id: event.id).first
              player2 = Player.where(user_id: @invitation.sender_id).where(event_id: event.id).first
              if player1.present? and player2.present?
                players << player1
                players << player2
                Team.create_team(bracket, players)
              else
                @invitation.status = :pending_confirmation
                @invitation.save!
                return json_response_error([t("player.partner.validation.invalid_inforamtion")], 422)
              end
            else
              @invitation.status = :pending_confirmation
              @invitation.save!
              return json_response_error([t("player.partner.validation.invalid_inforamtion")], 422)
            end
            if bracket.parent_bracket.present?
              type = bracket.parent_bracket.contest_bracket.bracket_type
            else
              type = bracket.contest_bracket.bracket_type
            end
            case type
            when "age"
              if bracket.age.present?
                @bracket_description = "Age: #{bracket.age}"
              else
                @bracket_description = "Young age: #{bracket.young_age}, Old age: #{bracket.old_age}"
              end
            when "skill"
              @bracket_description = "Lowest skill: #{bracket.lowest_skill}, Highest skill: #{bracket.highest_skill}"
            when "skill_age"
              main_bracket = bracket.parent_bracket
              if main_bracket.nil?
                main_bracket = bracket
              end
              if bracket.age.present?
                age = "Age: #{bracket.age}"
              else
                age = "Young age: #{bracket.young_age}, Old age: #{bracket.old_age}"
              end
              @bracket_description = "Lowest skill: #{main_bracket.lowest_skill}, Highest skill: #{main_bracket.highest_skill} [#{age}]"
            when "age_skill"
              main_bracket = bracket.parent_bracket
              if main_bracket.nil?
                main_bracket = bracket
              end
              skill = "Lowest skill: #{bracket.lowest_skill}, Highest skill: #{bracket.highest_skill}"
              if bracket.age.present?
                @bracket_description = "Age: #{main_bracket.age} [#{skill}]"
              else
                @bracket_description = "Young age: #{main_bracket.young_age}, Old age: #{main_bracket.old_age} [#{skill}]"
              end
            end
          end

          topic = "user_chanel_#{@invitation.sender_id}"
          user_to = @invitation.user
          #topic = 'user_chanel_3'
          options = {data: {type: "accept_invitation", id: @invitation.id}, collapse_key: "invitation", notification: {
              body: "#{user_to.first_name}, #{user_to.last_name}, has accepted your invitation on Tournament #{event.title} and Bracket #{@bracket_description}", sound: 'default'}}
          send_push_topic(topic, options)
        end
      end
    end
    json_response_success(t("edited_success", model: Invitation.model_name.human), true)
  end

  swagger_path '/invitations/download_template.xlsx' do
    operation :get do
      key :summary, 'Invitations download template'
      key :description, 'Invitations'
      key :operationId, 'invitationsDownloadTemplate'
      key :produces, ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',]
      key :tags, ['invitations']
      response 200 do
        key :description, 'template'
        key :type, 'file'
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def download_template
    send_file("#{Rails.root}/app/assets/template/invitations_template.xlsx",
              filename: "invitations_template.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  swagger_path '/invitations/template_sing_up.xlsx' do
    operation :get do
      key :summary, 'Invitations download template sing up'
      key :description, 'Invitations'
      key :operationId, 'invitationsDownloadTemplateSingUp'
      key :produces, ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',]
      key :tags, ['invitations']
      response 200 do
        key :description, 'template'
        key :type, 'file'
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def template_sing_up
    send_file("#{Rails.root}/app/assets/template/invitations_template_sign_up.xlsx",
              filename: "invitations_template_sign_up.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  swagger_path '/invitations/:id/refuse' do
    operation :post do
      key :summary, 'Invitations refuse'
      key :description, 'Invitations'
      key :operationId, 'invitationsRefuse'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :attendee_types
        key :in, :body
        key :required, true
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def refuse
    @invitation = Invitation.find(params[:id])
    @invitation.status = "declined"
    @invitation.save!(:validate => false)
    json_response_success(t("refuse_success", model: Invitation.model_name.human), true)
  end

  swagger_path '/invitations/partner' do
    operation :post do
      key :summary, 'Invitations partner'
      key :description, 'Invitations'
      key :operationId, 'invitationsSendPartner'
      key :produces, ['application/json',]
      key :tags, ['invitations']
      parameter do
        key :name, :event_id
        key :in, :body
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :partner_id
        key :in, :body
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :type
        key :in, :body
        key :description, "partner_mixed or partner_double"
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :url
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :for_registered
        key :description, '1 for need a partner or 0 for choose a partner'
        key :in, :body
        key :required, true
        key :type, :integer
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def partner
    event = Event.find(partner_params[:event_id])
    # player = Player.where(user_id: @resource.id).where(event_id: event.id).first
    type = ["partner_mixed", "partner_double"].include?(partner_params[:type]) ? partner_params[:type] : nil
    selector = [1, 0, "1", "0"].include?(partner_params[:for_registered]) ? partner_params[:for_registered] : nil
    #set brackets
    category_id = 0
    email = nil
    if partner_params[:email].present?
      email = partner_params[:email]
      to_user = User.where(:email => email).first
      unless to_user.nil?
        to_user.sync_invitation
      end
    else
      to_user = User.find(partner_params[:partner_id])
      unless to_user.nil?
        email = to_user.email
        to_user.sync_invitation
      end
    end
    if type == "partner_mixed"
      category_id = Category.single_mixed_category
    elsif type == "partner_double"
      if @resource.present?
        if @resource.gender == "Male"
          category_id = Category.single_men_double_category
        elsif @resource.gender == "Female"
          category_id = Category.single_women_double_category
        end
      end
      category_ids = Category.doubles_categories
    end
    bracket = EventContestCategoryBracketDetail.where(:id => partner_params[:bracket_id]).first
    if bracket.nil?
      return response_no_category
    end
    unless selector.present?
      return response_no_param
    end
    unless event.present?
      return response_no_event
    end
    unless type.present?
      return response_no_type
    end
    my_url = ""
    if selector.to_s == "1"
      my_url = Rails.configuration.front_partner_url
    elsif selector.to_s == "0"
      my_url = Rails.configuration.front_partner_choose_url
    end
    brackets = []
    if email.present?
      brackets << bracket
      my_url = my_url.gsub '{event_id}', event.id.to_s
      data = {:event_id => partner_params[:event_id], :email => email, :url => partner_params[:url], attendee_types: [AttendeeType.player_id]}
      @invitation = Invitation.get_invitation(data, @resource.id, type)
      my_url = my_url.gsub '{invitation_type}', @invitation.invitation_type
      @invitation.url = Invitation.short_url((my_url.gsub '{id}', @invitation.id.to_s))
      @invitation.save!
      @invitation.send_mail(true)
      brackets.each do |item|
        saved = @invitation.brackets.where(:event_bracket_id => item.id, :category_id => category_id).first
        if saved.nil?
          @invitation.brackets.create!({:event_bracket_id => item.id, :category_id => category_id})
        end
      end
    else
      return json_response_error([t("no_email")], 422)
    end
    json_response_success(t("created_success", model: Invitation.model_name.human), true)
  end


  def brackets
    @invitation = Invitation.where(:id => params[:id]).first!
    only_brackets = @invitation.brackets.pluck(:event_bracket_id)
    contest_id = EventContestCategoryBracketDetail.where(:id => only_brackets).pluck(:contest_id)
    @event = Event.find(@invitation.event_id)
    user = @resource
    user.sync_invitation
    player = Player.where(user_id: user.id).where(event_id: @event.id).first
    response_data = @event.available_categories(user, player, contest_id, only_brackets)
    if response_data.length <= 0
      return response_message_error(t("not_brackets_for_player"), 2)
    end
    json_response_serializer_collection(response_data, EventContestFilterCategorySerializer)
  end

  private

  def save(type)
    @invitation = Invitation.get_invitation(resource_params, @resource.id, type)
    case @invitation.invitation_type
    when "event"
      my_url = Rails.configuration.front_event_url.gsub '{id}', @invitation.event_id.to_s
      my_url = my_url.gsub '{invitatio_id}', @invitation.id.to_s
    when "date"
      my_url = Rails.configuration.front_date_url.gsub '{id}', @invitation.event_id.to_s
      my_url = my_url.gsub '{invitatio_id}', @invitation.id.to_s
    when "sing_up"
      my_url = Rails.configuration.front_sing_up_url
    end
    @invitation.url = Invitation.short_url(my_url)
    @invitation.save!(:validate => false)
    event = @invitation.event
    if event.registration_rule.allow_group_registrations or (event.present? and event.creator_user_id == @resource.id)
      @invitation.send_mail
      json_response_success(t("created_success", model: Invitation.model_name.human), true)
    else
      return render_not_permit_error
    end
  end

  def save_array(type)
    my_url = ""
    if is_array_save?
      @invitations = []
      array_params[:invitations].each {|invitation|
        invitation_save = Invitation.get_invitation(invitation, @resource.id, type)
        case invitation_save.invitation_type
        when "event"
          my_url = Rails.configuration.front_event_url.gsub '{id}', invitation_save.event_id.to_s
          my_url = my_url.gsub '{invitatio_id}', invitation_save.id.to_s
        when "date"
          my_url = Rails.configuration.front_date_url.gsub '{id}', invitation_save.event_id.to_s
          my_url = my_url.gsub '{invitatio_id}', invitation_save.id.to_s
        when "sing_up"
          my_url = Rails.configuration.front_sing_up_url
        end
        invitation_save.url = Invitation.short_url(my_url)
        invitation_save.save!
        @invitations << invitation_save
      }
      @invitations.each {|invitation|
        event = invitation.event
        if invitation.invitation_type == "date" or invitation.invitation_type == "sing_up" or (event.present? and (event.registration_rule.nil? or event.registration_rule.allow_group_registrations) or event.creator_user_id == @resource.id)
          invitation.send_mail
        else
          return render_not_permit_error
        end
      }
      json_response_success(t("created_success", model: Invitation.model_name.human), true)
    else
      json_response_success("no data", 200)
    end
  end

  def resource_params
    # whitelist params
    params.permit(:event_id, :email, :url, attendee_types: [])
  end

  def array_params
    params.permit(invitations: [:event_id, :email, :url, attendee_types: []])
  end

  def enroll_params
    params.permit(attendee_types: [])
  end

  def import_params
    params.permit(:event_id, :file)
  end

  def set_resource
    @invitation = InvitationPolicy::Scope.new(current_user, Invitation).resolve.find(params[:id])
  end

  def is_array_save?
    array_params[:invitations].present? and array_params[:invitations].kind_of?(Array)
  end

  def render_not_permit_error
    json_response_error([t("not_permitted")], 422)
  end

  def partner_params
    params.required(:for_registered)
    params.required(:event_id)
    params.required(:bracket_id)
    params.permit(:event_id, :partner_id, :type, :url, :for_registered, :email, :bracket_id)
  end

  def response_no_event
    json_response_error([t("not_event")], 422)
  end

  def response_no_param
    json_response_error([t("not_param")], 422)
  end

  def response_no_type
    json_response_error([t("not_type")], 422)
  end

  def response_no_category
    json_response_error([t("not_subscribe_to_category")], 422)
  end

  def index_partners_params
    params.required(:event_id)
  end

  def response_message_error(message, code)
    json_response_error(message, 422, code)
  end

end
