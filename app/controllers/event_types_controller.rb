class EventTypesController < ApplicationController
  def index
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'name': params[:column]
    direction = params[:direction].nil? ? 'asc': params[:direction]
    paginate EventType.unscoped.my_order(column, direction).search(search), per_page: 50, root: :data
  end

end
