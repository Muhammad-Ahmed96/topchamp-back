class ParticipantsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update_attendee_types, :activate, :inactive]
  before_action :authenticate_user!
  swagger_path '/participants' do
    operation :get do
      key :summary, 'List participants'
      key :description, 'Participants Catalog'
      key :operationId, 'participantsIndex'
      key :produces, ['application/json',]
      key :tags, ['participants']
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
        key :description, 'Direction to order'
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
        key :name, :first_name
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :status
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :event_id
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :event_title
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :attendee_type_id
        key :in, :query
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Participant Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Participant
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
    column = params[:column].nil? ? 'event_title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    status = params[:status]
    event_id = params[:event_id]
    event_title = params[:event_title]
    attendee_type_id = params[:attendee_type_id]

    event_title_column = nil
    if column.to_s == "event_title"
      event_title_column = "title"
      column = nil
    end
    attendee_type_column = nil
    if column.to_s == "attendee_type"
      attendee_type_column = "name"
      column = nil
    end
    user_column = nil
    if column.to_s == "first_name" or  column.to_s == "last_name" or column.to_s == "email"
      user_column = column
      column = nil
    end
    participants = Participant.my_order(column, direction).first_name_like(first_name).last_name_like(last_name).email_like(email)
                       .status_in(status).event_in(event_id).attendee_type_in(attendee_type_id).event_order(event_title_column, direction)
                       .attendee_type_order(attendee_type_column, direction)
                       .event_like(event_title).user_order(user_column, direction)
    if paginate.to_s == "0"
      json_response_serializer_collection(participants.all, ParticipantSerializer)
    else
      paginate participants, per_page: 50, root: :data
    end

  end

  swagger_path '/participants/:id' do
    operation :get do
      key :summary, 'Show participant'
      key :description, 'Participants Catalog'
      key :operationId, 'participantsShow'
      key :produces, ['application/json',]
      key :tags, ['participants']
      response 200 do
        schema do
          property :data do
            key :'$ref', :Participant
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

  def show
    json_response_serializer(@participant, ParticipantSerializer)
  end

  swagger_path '/participants/:id/update_attendee_types' do
    operation :put do
      key :summary, 'Update attendee types participant'
      key :description, 'Participants Catalog'
      key :operationId, 'participantsUpdateAttendeeTypes'
      key :produces, ['application/json',]
      key :tags, ['participants']
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
          key :'$ref', :Event
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

  def update_attendee_types
    if attendee_types_params[:attendee_types].present? and attendee_types_params[:attendee_types].kind_of?(Array)
      @participant.attendee_type_ids = attendee_types_params[:attendee_types]
    end
    json_response_serializer(@participant, ParticipantSerializer)
  end

  swagger_path '/participants/:id/activate' do
    operation :put do
      key :summary, 'Activate participant'
      key :description, 'Participants Catalog'
      key :operationId, 'participantsActivate'
      key :produces, ['application/json',]
      key :tags, ['participants']
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

  def activate
    @participant.status = :Active
    @participant.save!(:validate => false)
    json_response_success(t("activated_success", model: Participant.model_name.human), true)
  end

  swagger_path '/participants/:id/inactive' do
    operation :put do
      key :summary, 'Inactive participant'
      key :description, 'Participants Catalog'
      key :operationId, 'participantsInactive'
      key :produces, ['application/json',]
      key :tags, ['participants']
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

  def inactive
    @participant.status = :Inactive
    @participant.save!(:validate => false)
    json_response_success(t("inactivated_success", model: Participant.model_name.human), true)
  end

  private

  def attendee_types_params
    params.permit(attendee_types: [])
  end

  def set_resource
    @participant = Participant.find(params[:id])
  end
end
