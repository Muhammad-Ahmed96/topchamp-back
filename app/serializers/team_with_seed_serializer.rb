class TeamWithSeedSerializer < ActiveModel::Serializer
  attributes :id, :seed, :name
  has_many :players, :serializer => PlayerSingleSerializer

  def seed
    object.seed(instance_options[:tournament_id])
  end
end
