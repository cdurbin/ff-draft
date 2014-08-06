class CreateDefenses < ActiveRecord::Migration
  def change
    create_table :defenses, primary_key: 'player_id' do |t|
      t.string  :display_name
      t.integer :fantasy_points
      t.integer :fumble_rec
      t.integer :td
      t.integer :interceptions
      t.integer :sacks
      t.integer :special_team_td
      t.string  :team
      t.timestamps
    end
  end
end
