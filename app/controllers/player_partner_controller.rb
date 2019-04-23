class PlayerPartnerController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  swagger_path '/players/partners' do
    operation :post do
      key :summary, 'Save partner associated with player'
      key :description, 'Players Catalog'
      key :operationId, 'playersSavePartners'
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
        key :name, :partner_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :body
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
  def add_partner
    # TODO CREATE PARTNER
    if result == false
      return json_response_error([t("player.partner.validation.invalid_inforamtion")])
    end
    json_response_success(t("created_success", model: Team.model_name.human), true )
  end

  swagger_path '/players/partners' do
    operation :get do
      key :summary, 'Get partners list'
      key :description, 'Players Catalog'
      key :operationId, 'usersPartnersIndex'
      key :produces, ['application/json',]
      key :tags, ['players']
      parameter do
        key :name, :search
        key :in, :query
        key :description, 'Keyword to search'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :role
        key :in, :query
        key :description, 'Filter role'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :column
        key :in, :query
        key :description, 'Column to order special "sport_name" parameter for sports order'
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
        key :name, :status
        key :in, :query
        key :description, 'Status filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :first_name
        key :in, :query
        key :description, 'First name filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :query
        key :description, 'Last name filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :gender
        key :in, :query
        key :description, 'Gender filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :query
        key :description, 'Email filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :last_sign_in_at
        key :in, :query
        key :description, 'Last sign filter format(Y-m-d)'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :query
        key :description, 'City filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :birth_date
        key :in, :query
        key :description, 'Birth date format(Y-m-d)'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :sport_id
        key :in, :query
        key :description, 'Id of te sport filter'
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
        key :description, 'My Partner Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :User
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
  def get_my_partners
    #get my partners ids
    my_players_ids = @resource.players.pluck(:id)
    teams_ids = Team.joins(:players).merge(Player.where(:id => my_players_ids)).pluck(:id)
    players_ids = Player.where.not(:id => my_players_ids).joins(:teams).merge(Team.where(:id => teams_ids)).pluck(:id)
    #filter of my partners
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'first_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    status = params[:status]
    role = params[:role]
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = params[:gender]
    email = params[:email]
    last_sign_in_at = params[:last_sign_in_at]
    state = params[:state]
    city = params[:city]
    sport_id = params[:sport_id]
    birth_date = params[:birth_date]
    column_contact_information = nil
    column_sports = nil
    if column.to_s == "state" || column.to_s == "city"
      column_contact_information = column
      column = nil
    end
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end

    #partners_ids =  User.joins(:players).merge(Player.where(:id => players_ids)).pluck(:id)
    users =  User.joins(:players).merge(Player.where(:id => players_ids)).my_order(column, direction).search(search).in_role(role).birth_date_in(birth_date)
                 .in_status(status).first_name_like(first_name).last_name_like(last_name).gender_like(gender)
                 .email_like(email).last_sign_in_at_like(last_sign_in_at).state_like(state).city_like(city)
                 .sport_in(sport_id).contact_information_order(column_contact_information, direction).sports_order(column_sports, direction)
    if paginate.to_s == "0"
      json_response_serializer_collection(users.all, UserSingleSerializer)
    else
      paginate users, per_page: 50, root: :data,  each_serializer: UserSingleSerializer
    end
  end

  private

  def add_partner_params
    # whitelist params
    params.required(:event_id)
    params.required(:partner_id)
    params.required(:bracket_id)
    params.required(:category_id)
    params.permit(:partner_id, :event_id, :bracket_id, :category_id)
  end
end
