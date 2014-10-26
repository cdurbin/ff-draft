class CreateWeeklyRankings < ActiveRecord::Migration
  def change
    create_table :weekly_rankings do |t|
      t.integer :player_id
      t.string :name
      t.integer :week
      t.string :position
      t.string :team
      t.float :standard
      t.float :standard_low
      t.float :standard_high
      t.float :ppr
      t.float :ppr_low
      t.float :ppr_high
      t.string :injury
      t.string :practice_status
      t.string :game_status
      t.string :last_update
      t.timestamps
    end
  end
end
