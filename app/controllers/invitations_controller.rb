class InvitationsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :resend_mail, :enroll]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:event, :date, :sing_up, :enroll]
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
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :Sport
            end
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

  def show
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
    if @invitation.status != "role"
      event = @invitation.event
      if event.present?
        my_enroll = event.enrolls.where(:user_id => @invitation.user_id).first
        data = {:user_id => @invitation.user_id, enroll_status: :enroll}
        #Save data
        if my_enroll.present?
          my_enroll.update! data
        else
          my_enroll = event.enrolls.create!(data)
        end
        my_enroll.attendee_type_ids = @invitation.attendee_type_ids


        #my_enroll = event.add_enroll(@invitation.user_id, enroll[:category_id], enroll[:event_bracket_age_id], enroll[:event_bracket_skill_id], @invitation.attendee_type_ids)

        @invitation.status = :role
        @invitation.save!
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

  private

  def save(type)
    @invitation = Invitation.get_invitation(resource_params, @resource.id, type)
    event = @invitation.event
    if event.registration_rule.allow_group_registrations or (event.present? and event.creator_user_id == @resource.id)
      @invitation.send_mail
      json_response_success(t("created_success", model: Invitation.model_name.human), true)
    else
      return render_not_permit_error
    end
  end

  def save_array(type)
    if is_array_save?
      @invitations = []
      array_params[:invitations].each {|invitation|
        @invitations << Invitation.get_invitation(invitation, @resource.id, type)
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
end
