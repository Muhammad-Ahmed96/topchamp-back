class SuccessModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :SuccessModel do
    property :success do
      key :type, :boolean
      key :default , true
    end
    property :message do
      key :type, :string
    end
  end
end