class PlayersController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:update, :create]
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
        key :name, :bracket_age_id
        key :in, :query
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :bracket_skill_id
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
    bracket_age = params[:bracket_age_id]
    bracket_skill = params[:bracket_skill_id]
    skill_level = params[:skill_level]
    status = params[:status]
    role = params[:role]


    event_title_column = nil
    if column.to_s == "event_title"
      event_title_column = "title"
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

    bracket_age_column = nil
    if column.to_s == "bracket"
      bracket_age_column = "age"
      column = nil
    end

    bracket_skill_column = nil
    if column.to_s == "bracket"
      bracket_skill_column = "lowest_skill"
      column = nil
    end

    players = Player.my_order(column, direction).event_like(event_title).first_name_like(first_name).last_name_like(last_name)
    .email_like(email).category_in(category).bracket_age_in(bracket_age).bracket_skill_in(bracket_skill).skill_level_like(skill_level)
    .status_in(status).event_order(event_title_column, direction).first_name_order(first_name_column, direction)
                  .last_name_order(last_name_column, direction).email_order(email_column, direction).sport_in(sport)
                  .sports_order(sports_column, direction).categories_order(category_column, direction).bracket_age_order(bracket_age_column, direction)
                  .bracket_skill_order(bracket_skill_column, direction).role_in(role)
      if paginate.to_s == "0"
      json_response_serializer_collection(players.all, PlayerSerializer)
    else
      paginate players, per_page: 50, root: :data
    end
  end
  swagger_path '/players' do
    operation :get do
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
  def create
    authorize Player
    data = create_params.merge(:status => :Active)
    player = Player.where(:user_id =>data[:user_id]).where(:event_id => data[:event_id]).first
    if player.present?
      player.update!(data)
    else
      Player.create!(data)
    end
    json_response_success(t("created_success", model: Player.model_name.human), true)
  end
  swagger_path '/players/:id' do
    operation :post do
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
    if enroll_collection_params.present?
      enrolls_ids = []
      enroll_collection_params.each {|enroll|
        data = enroll.merge(:user_id => @player.user_id)
        my_enroll = @player.event.enrolls.where(:user_id => data[:user_id]).where(:category_id => data[:category_id]).first
        #Get status
        age = EventBracketAge.where(:event_id => @player.event_id).where(:id => data[:event_bracket_age_id]).first
        skill = EventBracketSkill.where(:event_id => @player.event_id).where(:id => data[:event_bracket_skill_id]).first

        # if my_enroll.nil?
        if age.present? && skill.present?
          if skill.event_bracket_age_id == age.id
            if skill.available_for_enroll
              data = data.merge(:enroll_status => :enroll)
            end
          elsif age.event_bracket_skill_id == skill.id
            if age.available_for_enroll
              data = data.merge(:enroll_status => :enroll)
            end
          end
        elsif age.present?
          if age.available_for_enroll
            data = data.merge(:enroll_status => :enroll)
          end
        elsif skill.present?
          if skill.available_for_enroll
            data = data.merge(:enroll_status => :enroll)
          end
        elsif my_enroll.nil?
          data = data.merge(:enroll_status => :wait_list)
        end
        #end

        if my_enroll.nil? and data[:enroll_status].nil?
          data = data.merge(:enroll_status => :wait_list)
        end

=begin
        if data[:status].equal? :wait_list
          return response_no_space_error
        end
=end

        #Save data
        if my_enroll.present?
          my_enroll.update! data
          #Player attendee
        else
          my_enroll = @player.event.enrolls.create!(data)
          my_enroll.attendee_type_ids = 7
        end

        enrolls_ids << my_enroll.id
      }
      @player.event.enrolls.where.not(id: enrolls_ids).destroy_all
    end
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


  private
  def create_params
    params.permit(:user_id, :event_id)
  end

  def set_resource
    @player = Player.find(params[:id])
  end


  def enroll_collection_params
    unless params[:enrolls].nil? and !params[:enrolls].kind_of?(Array)
      params[:enrolls].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :event_bracket_age_id, :event_bracket_skill_id)
      end
    end
  end
end
