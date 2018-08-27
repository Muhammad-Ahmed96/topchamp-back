class Category < ApplicationRecord
  include Swagger::Blocks


  def self.men_categories
    [1,2, 5]
  end

  def self.women_categories
    [3,4, 5]
  end

  def self.mixed_categories
    [5]
  end


  def self.doubles_categories
    [2,4]
  end

  def self.single_categories
    [1,3]
  end

  def self.single_mixed_category
    return 5
  end

  def self.single_men_double_category
    return 2
  end

  def self.single_women_double_category
    return 4
  end

  swagger_schema :Category do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of Category"
    end
    property :name do
      key :type, :string
      key :description, "Name string"
    end
  end

  swagger_schema :CategoryBrackets do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of Category Brackets"
    end
    property :name do
      key :type, :string
      key :description, "Name of Category Brackets"
    end
    property :brackets do
      key :type, :array
      items do
        key :'$ref', :EventBracket
      end
      key :description, "Brackets of Category Brackets"
    end
  end

  swagger_schema :CategoryInput do
    key :required, [:name]
    property :name do
      key :type, :string
      key :description, "Brackets of Category"
    end
  end
end
