class AddScoringSettingsToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :scoring_settings_id, :integer
  end
end
