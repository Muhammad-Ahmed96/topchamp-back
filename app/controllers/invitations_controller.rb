class InvitationsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :resend_mail]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:event, :date, :sing_up]

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

  def event
    authorize Invitation
    if is_array_save?
      save_array :event
    else
      save :event
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

  private

  def save(type)
    @invitation = Invitation.get_invitation(resource_params,  @resource.id, type)
    @invitation.send_mail
    json_response_success(t("created_success", model: Invitation.model_name.human), true)
  end

  def save_array(type)
    if is_array_save?
      @invitations = []
      array_params[:invitations].each {|invitation|
        @invitations <<  Invitation.get_invitation(invitation,  @resource.id, type)
      }
      @invitations.each {|invitation| invitation.send_mail}
      json_response_success(t("created_success", model: Invitation.model_name.human), true)
    else
      json_response_success("no data", 200)
    end
  end

  def resource_params
    # whitelist params
    params.permit(:event_id, :attendee_type_id, :email)
  end

  def array_params
    params.permit(invitations: [:event_id, :attendee_type_id, :email])
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
end
