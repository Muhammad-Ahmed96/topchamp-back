class User < ActiveRecord::Base
  include Swagger::Blocks
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  swagger_schema :User do
    key :required, [:id, :email, :provider, :uid, :allow_password_change, :name, :nickname, :image]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :email do
      key :type, :string
    end
    property :provider do
      key :type, :string
    end
    property :uid do
      key :type, :string
    end
    property :allow_password_change do
      key :type, :boolean
    end
    property :name do
      key :type, :string
    end
    property :nickname do
      key :type, :string
    end
    property :image do
      key :type, :string
    end
  end

end
