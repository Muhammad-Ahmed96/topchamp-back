class PlayersController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive, :partner]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:update, :create, :partner]
  swagger_path '/players' do
    operation :get do
      key :summary, 'List players'
      key :description, 'Players Catalog'
      key :operationId, 'playersIndex'
      key :produces, ['application/json',]
      key :tags, ['players']
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
        key :name, :event_title
        key :in, :query
        key :required, false
        key :type, :string
      end

      parameter do
        key :name, :category_id
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :bracket
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :skill_level
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :sport_id
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :role
        key :in, :query
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :Player
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
    authorize Player
    column = params[:column].nil? ? 'event_title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    event_title = params[:event_title]
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    category = params[:category_id]
    sport = params[:sport_id]
    bracket = params[:bracket]
    skill_level = params[:skill_level]
    status = params[:status]
    role = params[:role]


    event_column = nil
    if column.to_s == "event_title"
      event_column = "title"
      column = nil
    elsif column.to_s == "bracket"
      event_column = "bracket_by"
      column = nil
    end


    first_name_column = nil
    if column.to_s == "first_name"
      first_name_column = column
      column = nil
    end

    last_name_column = nil
    if column.to_s == "last_name"
      last_name_column = column
      column = nil
    end

    email_column = nil
    if column.to_s == "email"
      email_column = column
      column = nil
    end

    sports_column = nil
    if column.to_s == "sporst"
      sports_column = "name"
      column = nil
    end

    category_column = nil
    if column.to_s == "category"
      category_column = "name"
      column = nil
    end

    skill_level_column = nil
    if column.to_s == "skill_level"
      skill_level_column = "raking"
      column = nil
    end

    players = Player.my_order(column, direction).event_like(event_title).first_name_like(first_name).last_name_like(last_name)
                  .email_like(email).category_in(category).bracket_in(bracket).skill_level_like(skill_level)
                  .status_in(status).event_order(event_column, direction).first_name_order(first_name_column, direction)
                  .last_name_order(last_name_column, direction).email_order(email_column, direction).sport_in(sport)
                  .sports_order(sports_column, direction).categories_order(category_column, direction)
                  .role_in(role).skill_level_order(skill_level_column, direction)
    if paginate.to_s == "0"
      json_response_serializer_collection(players.all, PlayerSerializer)
    else
      paginate players, per_page: 50, root: :data
    end
  end

  swagger_path '/players' do
    operation :post do
      key :summary, 'Create players'
      key :description, 'Players Catalog'
      key :operationId, 'playersCreate'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :user_id
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :events
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

  def create
    authorize Player
    if create_params[:events].present? and create_params[:events].kind_of?(Array)
      create_params[:events].each do |event_id|
        data = {user_id: create_params[:user_id], event_id: event_id}
        Player.where(user_id: data[:user_id]).where(event_id: data[:event_id]).first_or_create!
      end
    else
      return json_response_error([t("events_required")], 422)
    end
    json_response_success(t("created_success", model: Player.model_name.human), true)
  end

  swagger_path '/players/:id' do
    operation :get do
      key :summary, 'Show players'
      key :description, 'Players Catalog'
      key :operationId, 'playersShow'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :user_id
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :event_id
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

  def show
    authorize @player
    json_response_serializer(@player, PlayerSerializer)
  end

  swagger_path '/players/:id' do
    operation :put do
      key :summary, 'Update players'
      key :description, 'Players Catalog'
      key :operationId, 'playersUpdate'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :enrolls
        key :in, :body
        key :description, 'Enrolls'
        key :type, :array
        items do
          key :'$ref', :EventEnrollInput
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

  def update
    authorize @player
    @player.sync_brackets! enroll_collection_params
    json_response_success(t("edited_success", model: Player.model_name.human), true)
  end

  swagger_path '/players/:id' do
    operation :delete do
      key :summary, 'Delete players'
      key :description, 'Players Catalog'
      key :operationId, 'playersDelete'
      key :produces, ['application/json',]
      key :tags, ['players']
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

  def destroy
    authorize @player
    @player.destroy
    json_response_success(t("deleted_success", model: Player.model_name.human), true)
  end

  swagger_path '/players/:id/activate' do
    operation :put do
      key :summary, 'Activate players'
      key :description, 'Players Catalog'
      key :operationId, 'playersActivate'
      key :produces, ['application/json',]
      key :tags, ['players']
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
    authorize Player
    @player.status = :Active
    @player.save!(:validate => false)
    json_response_success(t("activated_success", model: Player.model_name.human), true)
  end

  swagger_path '/players/:id/inactive' do
    operation :put do
      key :summary, 'Inactive players'
      key :description, 'Players Catalog'
      key :operationId, 'playersInactive'
      key :produces, ['application/json',]
      key :tags, ['players']
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
    authorize Player
    @player.status = :Inactive
    @player.save!(:validate => false)
    json_response_success(t("inactivated_success", model: Player.model_name.human), true)
  end
  swagger_path '/players/partner_double' do
    operation :post do
      key :summary, 'Partner double players'
      key :description, 'Players Catalog'
      key :operationId, 'playersPartnerDouble'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :partner_id
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :event_id
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

  def partner_double
    authorize Player
    to_user = User.find( partner_params[:partner_id])
    if params[:url].nil?
      params[:url] = "localhost/test"
    end
    if to_user.present?
      data = {:event_id => partner_params[:event_id], :email => to_user.email, :url => partner_params[:url], attendee_types: [AttendeeType.player_id]}
      @invitation = Invitation.get_invitation(data, @resource.id, "partner_double")
      @invitation.send_mail
    else
      return json_response_error([t("no_player")], 422)
    end
    json_response_success(t("edited_success", model: Player.model_name.human), true)
  end
  swagger_path '/players/partner_mixed' do
    operation :post do
      key :summary, 'Partner mixed players'
      key :description, 'Players Catalog'
      key :operationId, 'playersPartnerMixed'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :partner_id
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :event_id
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
  def partner_mixed
    authorize Player
    to_user = User.find( partner_params[:partner_id])
    if params[:url].nil?
      params[:url] = "localhost/test"
    end
    if to_user.present?
      data = {:event_id => partner_params[:event_id], :email => to_user.email, :url => partner_params[:url], attendee_types: [AttendeeType.player_id]}
      @invitation = Invitation.get_invitation(data, @resource.id, "partner_mixed")
      @invitation.send_mail
    else
      return json_response_error([t("no_player")], 422)
    end
    json_response_success(t("edited_success", model: Player.model_name.human), true)
  end


  private

  def create_params
    params.permit(:user_id, events: [])
  end

  def set_resource
    @player = Player.find(params[:id])
  end

  def partner_params
    params.permit(:event_id, :partner_id, :url)
  end


  def enroll_collection_params
    unless params[:enrolls].nil? and !params[:enrolls].kind_of?(Array)
      params[:enrolls].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :event_bracket_age_id, :event_bracket_skill_id)
      end
    end
  end
end
