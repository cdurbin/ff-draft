class CreatePlayerScores < ActiveRecord::Migration
  def change
    create_table :player_scores do |t|
      t.integer :player_id
      t.string :display_name
      t.integer :scoring_settings_id
      t.float :fantasy_points
      t.string :position
      t.timestamps
    end
  end
end
