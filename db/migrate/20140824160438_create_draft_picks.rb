class CreateDraftPicks < ActiveRecord::Migration
  def change
    create_table :draft_picks do |t|
      t.integer :player_id
      t.integer :draft_id
      t.integer :pick_number
      t.timestamps
    end
  end
end
