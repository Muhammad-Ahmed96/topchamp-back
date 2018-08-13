class CreateTeamsPlayerJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table  :teams, :players do |t|
      t.index :team_id
      t.index :player_id
    end
  end
end
