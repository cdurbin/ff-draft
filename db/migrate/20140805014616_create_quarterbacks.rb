class CreateQuarterbacks < ActiveRecord::Migration
  def change
    create_table :quarterbacks, primary_key: 'player_id'  do |t|
      t.string  :display_name
      t.integer :fantasy_points
      t.integer :attempts
      t.integer :completions
      t.integer :passing_int
      t.integer :passing_td
      t.integer :passing_yards
      t.integer :rush_td
      t.integer :rush_yards
      t.string  :team
      t.timestamps
    end
  end
end
