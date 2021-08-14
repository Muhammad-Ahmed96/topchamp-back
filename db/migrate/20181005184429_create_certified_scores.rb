class CreateCertifiedScores < ActiveRecord::Migration[5.2]
  def change
    create_table :certified_scores do |t|
      t.integer :match_id
      t.integer :event_id
      t.integer :tournament_id
      t.integer :round_id
      t.integer :team_a_id
      t.integer :team_b_id
      t.integer :team_winner_id
      t.integer :user_id
      t.datetime :date_at
      t.string :signature_file_name
      t.integer :signature_file_size
      t.string :signature_content_type
      t.datetime :signature_updated_at
      t.string :status
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :certified_scores, :deleted_at
  end
end
