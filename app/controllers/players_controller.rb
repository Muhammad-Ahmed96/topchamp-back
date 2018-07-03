class PlayersController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
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
                  .bracket_skill_order(bracket_skill_column, direction)
      if paginate.to_s == "0"
      json_response_serializer_collection(players.all, PlayerSerializer)
    else
      paginate players, per_page: 50, root: :data
    end
  end
end
