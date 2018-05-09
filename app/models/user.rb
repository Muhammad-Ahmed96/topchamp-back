class User < ApplicationRecord
  include Swagger::Blocks
  include DeviseTokenAuth::Concerns::User
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable

  validates :password, presence: false
  validates :first_name, length: { maximum: 50 }, presence: true
  validates :middle_initial, length: { maximum: 1 }, presence: true
  validates :last_name, length: { maximum: 50 }, presence: true
  validates :badge_name, length: { maximum: 50 }, presence: true
  validates :birth_date, presence: true
  validates :gender, inclusion: { in: Genders.collection },presence: true
  validates :role, inclusion: { in: Roles.collection }, presence: true

  swagger_schema :User do
    key :required, [:id, :email, :provider, :uid, :allow_password_change, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :image, :badge_name]
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
    property :first_name do
      key :type, :string
    end
    property :middle_initial do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :gender do
      key :type, :string
    end
    property :role do
      key :type, :string
    end
    property :birth_date do
      key :type, :string
    end
    property :badge_name do
      key :type, :string
    end
    property :image do
      key :type, :string
    end
  end

end
