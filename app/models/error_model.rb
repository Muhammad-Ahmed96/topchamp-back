class ErrorModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :ErrorModel do
    property :success do
      key :type, :boolean
      key :default , false
      key :description, "Success indicator"
    end
    property :errors do
      key :type, :array
      items do
        key :type, :string
      end
      key :description, "Erros messages"
    end
  end
end