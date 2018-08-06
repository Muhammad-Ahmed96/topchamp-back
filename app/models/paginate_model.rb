class PaginateModel  # Notice, this is just a plain ruby object.
  include Swagger::Blocks

  swagger_schema :PaginateModel do
      property :pagination do
        key :required, [:per_page, :total_pages, :total_objects, :links]
        property :per_page do
          key :type, :integer
          key :format, :int64
          key :description, "per page count"
        end
        property :total_pages do
          key :type, :integer
          key :format, :int64
          key :description, "total pages count"
        end
        property :total_objects do
          key :type, :integer
          key :format, :int64
          key :description, "total objects count"
        end
        property :links do
          key :required, [:first, :last]
          property :first do
            key :type, :string
            key :description, "First links to navigate"
          end
          property :last do
            key :type, :string
            key :description, "Last links to navigate"
          end
          key :description, "Links to navigate"
        end
        key :description, "Pagination data"
      end
      key :description, "Meta data of pagging"
    end
end