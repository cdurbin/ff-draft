class CreateKickers < ActiveRecord::Migration
  def change
    create_table :kickers, primary_key: 'player_id' do |t|
      t.string  :display_name
      t.integer :fantasy_points
      t.integer :fg
      t.integer :xp
      t.string  :team
      t.timestamps
    end
  end
end
