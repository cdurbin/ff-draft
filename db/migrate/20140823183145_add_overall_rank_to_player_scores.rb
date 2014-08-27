class AddOverallRankToPlayerScores < ActiveRecord::Migration
  def change
    add_column :player_scores, :overall_rank, :integer
  end
end
