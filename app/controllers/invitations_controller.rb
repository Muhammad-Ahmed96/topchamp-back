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
    player = Player.where(user_id: @resource.id).where(event_id: event_id).first_or_create!
    categories_ids = player.brackets.where.not(:payment_transaction_id => nil).distinct.pluck(:category_id)
    if categories_ids.included_in? Category.doubles_categories
      invitatin_type << "partner_double"
    end

    if categories_ids.included_in? Category.mixed_categories
      invitatin_type << "partner_mixed"
    end
    #end check if category is paid
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    invitations = Invitation.my_order(column, direction).event_like(event)
                      .email_like(email).first_name_like(first_name).last_name_like(last_name).event_order(eventColumn, direction).user_order(userColumn, direction)
                      .in_status(status).phone_like(phone).phone_order(phoneColumn, direction).in_type(type).where(:user_id => @resource.id).where(:event_id => event_id)
                      .where(:status => "pending_invitation").where(:invitation_type => invitatin_type)
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
    if @invitation.status != "role"
      event = @invitation.event
      if event.present?
        types = enroll_params[:attendee_types] #@invitation.attendee_type_ids
        if types.nil? or (!types.kind_of?(Array) or types.length <= 0)
          types = []
        end
        type_id = AttendeeType.player_id
        is_player = types.detect {|w| w == type_id}
        unless is_player.nil?
          #Create player
          types.delete(type_id)
          player = Player.where(user_id: @invitation.user_id).where(event_id: event.id).first_or_create!
        end
        if types.length > 0
          participant = Participant.where(:user_id => @invitation.user_id).where(:event_id => event.id).first_or_create!
          types = types + participant.attendee_type_ids.to_a
          participant.attendee_type_ids = types
        end
        @invitation.status = :role
        @invitation.save!
        category_id = nil
        if @invitation.invitation_type == "partner_mixed"
          category_id = Category.single_mixed_category
        elsif @invitation.invitation_type == "partner_double"
          user = User.find(@invitation.user_id)
          if user.present?
            if user.gender == "Male"
              category_id = Category.single_men_double_category
            elsif user.gender == "Female"
              category_id = Category.single_women_double_category
            end
          end
        end
        #ckeck partner brackets
        @invitation.brackets.each do |item|
          result = User.create_partner(@invitation.sender_id, event.id, @invitation.user_id, item.event_bracket_id, category_id)
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
    @invitation.status = "refuse"
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
    to_user = User.find(partner_params[:partner_id])
    event = Event.find(partner_params[:event_id])
    type = ["partner_mixed", "partner_double"].include?(partner_params[:type]) ? partner_params[:type] : nil
    unless event.present?
      return response_no_event
    end
    unless type.present?
      return response_no_type
    end
    my_url = Rails.configuration.front_partner_url
    if to_user.present?
      data = {:event_id => partner_params[:event_id], :email => to_user.email, :url => partner_params[:url], attendee_types: [AttendeeType.player_id]}
      @invitation = Invitation.get_invitation(data, @resource.id, type)
      @invitation.url = Invitation.short_url((my_url.gsub '{id}', @invitation.id.to_s))
      @invitation.save!
      @invitation.send_mail(true)
      #set brackets
      category_ids = []
      if type == "partner_mixed"
        category_ids = Category.mixed_categories
      elsif type == "partner_double"
        category_ids = Category.doubles_categories
      end
      player = Player.where(user_id: @resource.id).where(event_id: event.id).first_or_create!
      brackets = player.brackets.where(:category_id => category_ids).all
      brackets.each do |item|
        saved = @invitation.brackets.where(:event_bracket_id => item.event_bracket_id).first
        if saved.nil?
          @invitation.brackets.create!({:event_bracket_id => item.event_bracket_id})
        end
      end
    else
      return json_response_error([t("no_player")], 422)
    end
    json_response_success(t("created_success", model: Invitation.model_name.human), true)
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
        if invitation.invitation_type == "sing_up" or (event.present? and (event.registration_rule.nil? or event.registration_rule.allow_group_registrations) or event.creator_user_id == @resource.id)
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
    params.permit(:event_id, :partner_id, :type, :url)
  end

  def response_no_event
    json_response_error([t("not_event")], 422)
  end

  def response_no_type
    json_response_error([t("not_type")], 422)
  end

  def index_partners_params
    params.required(:event_id)
  end
end
