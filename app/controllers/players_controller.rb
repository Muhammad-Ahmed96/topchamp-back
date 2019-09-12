class PlayersController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive, :enrolled]
  around_action :transactions_filter, only: [:update, :create, :signature]
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
        key :description, 'Player Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Player
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', PaginateModel
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
    event = params[:event_id]
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    category = params[:category_id]
    sport = params[:sport_id]
    bracket = params[:bracket]
    skill_level = params[:skill_level]
    birth_date = params[:birth_date]
    gender = params[:gender]
    status = params[:status]
    role = params[:role]
    age = params[:age]


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
    if column.to_s == "sports"
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

    age_column = nil
    if column.to_s == "age" or column.to_s == "birth_date"
      age_column = "birth_date"
      column = nil
    end

    gender_column = nil
    if column.to_s == "gender"
      gender_column = "gender"
      column = nil
    end

    players = PlayerPolicy::Scope.new(current_user, Player).resolve.my_order(column, direction).event_like(event_title).first_name_like(first_name).last_name_like(last_name)
                  .email_like(email).category_in(category).bracket_in(bracket).skill_level_like(skill_level).birth_date_like(birth_date).event_in(event)
                  .status_in(status).event_order(event_column, direction).first_name_order(first_name_column, direction).gender_in(gender)
                  .last_name_order(last_name_column, direction).email_order(email_column, direction).sport_in(sport)
                  .sports_order(sports_column, direction).categories_order(category_column, direction).gender_order(gender_column, direction)
                  .role_in(role).skill_level_order(skill_level_column, direction).age_order(age_column, direction).age_like(age)
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
          key :'$ref', :PlayerBracketInput
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
    enrolls_old = @player.brackets_enroll.all.pluck(:event_bracket_id).to_a
    event = @player.event
    brackets = @player.event.available_brackets(player_brackets_params)
    @player.sync_brackets! brackets
    brackets_ids = @player.brackets_enroll.all.pluck(:event_bracket_id).to_a
    # @player.brackets.where(:enroll_status => :enroll).where(:payment_transaction_id => nil).where(:event_bracket_id => brackets.pluck(:event_bracket_id))
    #    .update(:payment_transaction_id => "000")
    enrolls_old.each do |item|
      if brackets_ids.exclude? item
        enroll = @player.brackets.where(:enroll_status => :enroll).where(:event_bracket_id => item)
                     .first
        if enroll.nil?
          @player.unsubscribe(nil, item)
        end
        tournament = Tournament.where(:event_id => event.id).where(:event_bracket_id => item).first
        if tournament.present? and tournament.have_score? == false
            tournament.delete
        end
      end
    end
    brackets_ids.each do |item|
      if enrolls_old.exclude? item
        tournament = Tournament.where(:event_id => event.id).where(:event_bracket_id => item).first
        if tournament.present? and tournament.have_score? == false
          tournament.delete
        end
      end
    end
    in_team_ids = @player.teams.where(event_bracket_id: brackets_ids).all.pluck(:event_bracket_id)
    only_ids = []
    if in_team_ids.size == 0
      only_ids = brackets_ids
    else
      brackets_ids.each do |id|
        if in_team_ids.exclude? id
          only_ids << id
        end
      end
    end

    my_brackets = @player.brackets_enroll.where(:event_bracket_id => only_ids)
    my_brackets.each do |bracket|
      category_type = ""
      if [bracket.category_id.to_i].included_in? Category.doubles_categories_exact
        category_type = "partner_double"
      elsif [bracket.category_id.to_i].included_in? Category.mixed_categories
        category_type = "partner_mixed"
      end
      invitation = Invitation.where(:event_id => @player.event_id).where(:user_id => @player.user_id).where(:status => :accepted).where(:invitation_type => category_type)
                       .joins(:brackets).merge(InvitationBracket.where(:event_bracket_id => bracket.event_bracket_id)).first
      if invitation.present?
        result = Player.validate_partner(@player.user_id, invitation.sender_id, bracket.event_bracket_id, bracket.category_id)
        if result == true
          bracket.update({:is_root => false, :partner_id => invitation.sender_id})
        end
      end
    end
    @player.set_teams(my_brackets)
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
    @player.unsubscribe_event
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
    @player.unsubscribe_event
    @player.save!(:validate => false)
    json_response_success(t("inactivated_success", model: Player.model_name.human), true)
  end

=begin
  swagger_path '/players/:id/wait_list' do
    operation :get do
      key :summary, 'Wait list of players'
      key :description, 'Players Catalog'
      key :operationId, 'playersWaitList'
      key :produces, ['application/json',]
      key :tags, ['players']
      response 200 do
        schema do
          property :data do
            items do
              key :'$ref', :PlayerBracket
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
  def wait_list
    #todo wait list
    json_response_serializer_collection(@player.brackets_wait_list, PlayerBracketSingleSerializer)
  end
=end
  swagger_path '/players/:id/enrolled' do
    operation :get do
      key :summary, 'brackets enrolled of players'
      key :description, 'Players Catalog'
      key :operationId, 'playersEnrolled'
      key :produces, ['application/json',]
      key :tags, ['players']
      response 200 do
        schema do
          property :data do
            items do
              key :'$ref', :PlayerBracket
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

  def enrolled
    json_response_serializer_collection(@player.brackets_enroll, PlayerBracketSingleSerializer)
  end

  swagger_path '/players/signature' do
    operation :post do
      key :summary, 'Signature associated with player'
      key :description, 'Players Catalog'
      key :operationId, 'playersSignature'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :event_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :signature
        key :in, :body
        key :required, true
        key :type, :string
        key :format, :binary
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

  def signature
    player = Player.where(user_id: @resource.id).where(event_id: signature_param[:event_id]).first
    if player.nil?
      return json_response_error([t("no_player")], 422)
    end
    player.signature = signature_param[:signature]
    player.save!(:validate => false)
    json_response_success(t("edited_success", model: Player.model_name.human), true)
  end


  swagger_path '/players/schedules' do
    operation :get do
      key :summary, 'Schedules associated with player'
      key :description, 'Players Catalog'
      key :operationId, 'playersSchedules'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :event_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :title
        key :in, :query
        key :description, 'Event filter'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Schedules Response'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', EventSchedule
            end
            key :description, "Information container"
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

  def get_schedules
    title = params[:title]
    player = Player.where(user_id: @resource.id).where(event_id: schedules_param[:event_id]).first
    schedules = player.present? ? player.schedules.title_like(title) : []
    json_response_serializer_collection(schedules, EventScheduleSerializer)
  end

  swagger_path '/players/validate_partner' do
    operation :get do
      key :summary, 'Validate partner information associated with player'
      key :description, 'Players Catalog'
      key :operationId, 'playersValidatePartner'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :event_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :partner_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
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

  def validate_partner
    player = Player.where(user_id: @resource.id).where(event_id: validate_partner_params[:event_id]).first
    if player.nil?
      return json_response_error([t("player.partner.validation.invalid_inforamtion")])
    end
    result = Player.validate_partner(validate_partner_params[:partner_id], @resource.id, validate_partner_params[:bracket_id], validate_partner_params[:category_id])
    if result != true
      return json_response_error([t("player.partner.validation.invalid_inforamtion")])
    end
    json_response_success(t("player.partner.validation.valid"), response)
  end

  swagger_path '/players/rounds' do
    operation :get do
      key :summary, 'Get rounds list player tournaments'
      key :description, 'Event Catalog'
      key :operationId, 'playersRoundsList'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :event_bracket_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Raound Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Raund
            end
            key :description, "Information container"
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

  def rounds
    player = Player.where(user_id: @resource.id).where(event_id: tournaments_list_params[:event_id]).first
    if player.nil?
      return json_response_error([t("no_player")], 422)
    end
    team = player.teams.where(:event_bracket_id => tournaments_list_params[:event_bracket_id]).first
    @tournament = Tournament.where(:event_id => player.event_id).where(:event_bracket_id => tournaments_list_params[:event_bracket_id])
                      .first
    if @tournament.nil?
      return json_response_error([t("no_tournament")], 422)
    end
    team_id = team.present? ? team.id : 0
    rounds = @tournament.rounds.joins(:matches).merge(Match.where(:team_a_id => team_id).or(Match.where(:team_b_id => team_id)))
    rounds.each do |item|
      item.for_team_id = team_id
    end
    json_response_serializer_collection(rounds, RoundMyMatchesSerializer)
  end

  swagger_path '/players/categories' do
    operation :get do
      key :summary, 'Get categories list player tournaments'
      key :description, 'Event Catalog'
      key :operationId, 'playersCategoriesList'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Categories Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Category
            end
            key :description, "Information container"
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

  def categories
    player = Player.where(user_id: @resource.id).where(event_id: categories_params[:event_id]).first
    if player.nil?
      return json_response_error([t("no_player")], 422)
    end
    in_categories_id = player.brackets_enroll.pluck(:category_id)
    json_response_serializer_collection(Category.where(:id => in_categories_id).all, CategorySerializer)
  end

  swagger_path '/players/brackets' do
    operation :get do
      key :summary, 'Get brackets list player tournaments'
      key :description, 'Event Catalog'
      key :operationId, 'playersBracketsList'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Brackets Response'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :PlayerBracket
            end
            key :description, "Information container"
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

  def brackets
    player = Player.where(user_id: @resource.id).where(event_id: brackets_list_params[:event_id]).first
    if player.nil?
      return json_response_error([t("no_player")], 422)
    end
    brackets = player.brackets_enroll
    brackets = brackets.where(:category_id => brackets_list_params[:category_id]) if brackets_list_params[:category_id].present?
    json_response_serializer_collection(brackets, PlayerBracketSingleSerializer)
  end

  swagger_path '/players/rival_info' do
    operation :get do
      key :summary, 'Get rival info'
      key :description, 'Event Catalog'
      key :operationId, 'playersRivalInfo'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :team_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Rival Response'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Player
            end
            key :description, "Information container"
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

  def rival_info
    players = Player.joins(:teams).merge(Team.where(:id => rival_params[:team_id]))
    json_response_serializer_collection(players, RivalInfoSerializer)
  end


  def available_brackets
    player = Player.find(params[:id])
    user = player.user
    event = Event.find(player.event_id)
    response_data = []
    contests = event.contests
    #contests = contests.where(:id => available_categories_params[:contest_id]) if available_categories_params[:contest_id].present?
    #Validate categories
    if contests.length <= 0
      return response_message_error(t("not_brackets_for_player"), 2)
    end
    #Validate skills
    contests.each do |contest|
      contest.filter_categories = event.available_categories(user, player, contest.id, nil, true)
      if contest.filter_categories.length > 0
        response_data << contest
      end
    end
    if response_data.length <= 0
      return response_message_error(t("not_brackets_for_player"), 2)
    end
    json_response_serializer_collection(response_data, EventContestFilterSerializer)
  end


  def update_brackets
    authorize Player.find(params[:id])
  end

  def my_contest
    player = Player.where(user_id: 110).where(event_id: categories_params[:event_id]).first
    if player.nil?
      return json_response_error([t("no_player")], 422)
    end
    brackets_ids = []
    details_ids = []
    player.brackets_enroll.all.each do |item|
      details_ids.push(item.event_bracket_id)
      unless item.bracket.nil?
        if item.bracket.event_contest_category_bracket_id.present?
          brackets_ids.push(item.bracket.event_contest_category_bracket_id)
        else
          brackets_idspush(item.bracket.parent_bracket.event_contest_category_bracket_id)
        end
      end
    end
    contest = EventContest.joins(:categories => [:brackets]).merge(EventContestCategoryBracket.where(:id => brackets_ids))
                  .where(:event_id => categories_params[:event_id]).all
    contest.each do |item|
      item.filter_categories = EventContestCategory.joins(:brackets).merge(EventContestCategoryBracket.where(:id => brackets_ids)).all
      item.filter_categories.each do |category|
        category.filter_brackets = category.brackets.where(:id => brackets_ids).all
        category.filter_brackets.each do |bracket|
          bracket.filter_details = bracket.details.where(:id => details_ids).all
          bracket.filter_details.each do |detail|
            detail.filter_brackets = detail.brackets.where(:id => details_ids).all
          end
        end
      end
    end
    json_response_serializer_collection(contest, EventContestFilterSerializer)
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


  def player_brackets_params
    unless params[:enrolls].nil? and !params[:enrolls].kind_of?(Array)
      params[:enrolls].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :event_bracket_id, :partner_id)
      end
    end
  end

  def response_no_event
    json_response_error([t("not_event")], 422)
  end

  def signature_param
    # whitelist params
    params.required(:event_id)
    params.required(:signature)
    params.permit(:signature, :event_id)
  end

  def schedules_param
    # whitelist params
    params.required(:event_id)
    params.permit(:event_id)
  end

  def validate_partner_params
    # whitelist params
    params.required(:event_id)
    params.required(:partner_id)
    params.required(:bracket_id)
    params.required(:category_id)
    params.permit(:partner_id, :event_id, :bracket_id, :category_id)
  end

  def tournaments_list_params
    # whitelist params
    params.required(:event_id)
    params.required(:category_id)
    params.required(:event_bracket_id)
    params.permit(:event_id, :category_id, :event_bracket_id)
  end

  def categories_params
    # whitelist params
    params.required(:event_id)
    params.permit(:event_id)
  end

  def brackets_list_params
    # whitelist params
    params.required(:event_id)
    params.permit(:event_id, :category_id)
  end

  def rival_params
    #params.required(:match_id)
    params.required(:team_id)
    params.permit(:match_id, :team_id)
  end

  def response_message_error(message, code)
    json_response_error(message, 422, code)
  end
end
