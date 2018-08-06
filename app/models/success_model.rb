class SuccessModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :SuccessModel do
    property :success do
      key :type, :boolean
      key :default , true
      key :description, "Succes status"
    end
    property :message do
      key :type, :string
      key :description, "Message status"
    end
  end

  swagger_schema :ResponseDataModel do
    property :data do
      key :type, :boolean
      key :default , true
      key :description, "Succes status"
    end
  end
end