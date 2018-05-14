class PaginateModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :PaginateModel do
    property :data do
      key :type, :array
    end

    property :meta do
      property :pagination do
        key :required, [:per_page, :total_pages, :total_objects, :links]
        property :per_page do
          key :type, :integer
          key :format, :int64
        end
        property :total_pages do
          key :type, :integer
          key :format, :int64
        end
        property :total_objects do
          key :type, :integer
          key :format, :int64
        end
        property :links do
          key :required, [:first, :last]
          property :first do
            key :type, :string
          end
          property :last do
            key :type, :string
          end
        end
      end
    end
  end
end