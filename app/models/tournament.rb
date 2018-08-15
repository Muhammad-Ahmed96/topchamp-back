class Tournament < ApplicationRecord
  include Swagger::Blocks
  belongs_to :event
  belongs_to :bracket, :class_name => "EventBracket", :foreign_key => "event_bracket_id"
  belongs_to :category

  has_many :rounds, -> {order_by_index}, :dependent => :destroy

  def sync_matches!(data)
    deleteIds = []
    if data.present?
      data.each do |item|
        match_ids = []
        if item[:id].present?
          round = self.rounds.where(:id => item[:id]).update_or_create!({:index => item[:index]})
        else
          round = self.rounds.where(:index => item[:index]).first_or_create!({:index => item[:index]})
        end
        if item[:matches].present?
          item[:matches].each do |item_match|
            if item_match[:id].present?
              match = round.matches.where(:id => item_match[:id]).update_or_create!(item_match)
            else
              match = round.matches.where(:index => item_match[:index]).update_or_create!(item_match)
            end
            match_ids << match.id
          end
        end
        round.matches.where.not(:id => match_ids).destroy_all
        deleteIds << round.id
      end
    else
      self.rounds.where.not(id: deleteIds).destroy_all
    end
  end

  swagger_schema :Tournament do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with tournament"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with tournament"
    end
    property :event_bracket_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event bracket id associated with tournament"
    end
    property :category_id do
      key :type, :integer
      key :format, :int64
      key :description, "Category id associated with tournament"
    end
    property :status do
      key :type, :string
      key :description, "Statusassociated with tournament"
    end
    property :event do
        key :'$ref', :Event
      key :description, "Event associated with tournament"
    end

    property :bracket do
      key :'$ref', :EventBracket
      key :description, "Bracket associated with tournament"
    end

    property :category do
      key :'$ref', :Category
      key :description, "Category associated with tournament"
    end

    property :rounds do
      key :type, :array
      items do
        key :'$ref', :Round
      end
      key :description, "Rounds associated with tournament"
    end
  end
end
