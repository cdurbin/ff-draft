class CreateTightEnds < ActiveRecord::Migration
  def change
    create_table :tight_ends, primary_key: 'player_id' do |t|
      t.string  :display_name
      t.integer :fantasy_points
      t.integer :fumbles
      t.integer :rec
      t.integer :rec_td
      t.integer :rec_yards
      t.integer :rush_att
      t.integer :rush_td
      t.integer :rush_yards
      t.string  :team
      t.timestamps
    end
  end
end
