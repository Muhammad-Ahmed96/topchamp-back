class ErrorModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :ErrorModel do
    key :required, [:success, :errors]
    property :success do
      key :type, :boolean
      key :default , false
    end
    property :errors do
      key :type, :array
      items do
        key :type, :string
      end
    end
  end
end