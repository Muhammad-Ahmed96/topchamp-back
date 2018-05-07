class SuccessModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :SuccessModel do
    key :required, [:success, :message]
    property :success do
      key :type, :boolean
      key :default , false
    end
    property :message do
      key :type, :string
    end
  end
end