class PartnersController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/partners' do
    operation :get do
      key :summary, 'Get partners'
      key :description, 'Partners Catalog'
      key :operationId, 'partnersIndex'
      key :produces, ['application/json',]
      key :tags, ['partners']
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
        key :name, :search
        key :in, :query
        key :description, 'Keyword to search'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :event_id
        key :in, :query
        key :description, 'Event to add'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :event_bracket_id
        key :in, :query
        key :description, 'Bracket id'
        key :required, true
        key :type, :integer
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
        key :description, 'Type {nil or doubles or mixed}'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :type_users
        key :in, :query
        key :description, 'Type {nil or all or registered}'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'Partner Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', User
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
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'first_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    event_id = params[:event_id]
    event = Event.where(id: event_id).first
    category_id = 0
    if event.nil?
      return json_response_error([t("not_event")], 422)
    end
    type_users = params[:type_users]
    type = params[:type]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    not_in = [@resource.id]
    gender = nil
    player = Player.where(user_id: @resource.id).where(event_id: event_id).first
    if type == "doubles"
      if player.present?
        not_in << player.partner_double_id
        gender = player.user.gender
        category_id = player.user.gender == "Male" ?  Category.single_men_double_category :  Category.single_women_double_category
      end
    elsif type == "mixed"
      if player.present?
        not_in << player.partner_mixed_id
        gender = player.user.gender == "Male" ? "Female" : "Male"
      end
      category_id = Category.single_mixed_category
    end
    users_in = nil
    if type_users == "registered"
      users_in = event.players.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => params[:event_bracket_id]).where(:category_id =>  category_id)).pluck(:user_id)
    else
      in_event = event.players.pluck(:user_id)
      not_in = not_in + in_event
    end
    users = User.my_order(column, direction).search(search).where.not(id: not_in).where(:gender => gender)
    if users_in.present?
      users = users.where(:id => users_in)
    end

    if paginate.to_s == "0"
      json_response_serializer_collection(users.all, UserSingleSerializer)
    else
      paginate users, per_page: 50, root: :data
    end
  end


  private

  def response_no_type_users
    json_response_error([t("not_type")], 422)
  end
end
