class CreateScoringSettings < ActiveRecord::Migration
  def change
    create_table :scoring_settings do |t|
      t.string :name
      t.float :passing_yards
      t.float :int_thrown
      t.float :passing_td
      t.float :rush_yards
      t.float :rush_td
      t.float :fumbles_lost
      t.float :rec
      t.float :rec_yards
      t.float :rec_td
      t.float :return_yards
      t.float :misc_td
      t.float :misc_2pc
      t.timestamps
    end
  end
end
