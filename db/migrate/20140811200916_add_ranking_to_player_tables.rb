class AddRankingToPlayerTables < ActiveRecord::Migration
  def change
    add_column :wide_receivers, :overall_rank, :integer
    add_column :wide_receivers, :position_rank, :integer
    add_column :wide_receivers, :nerd_rank, :float
    add_column :running_backs, :overall_rank, :integer
    add_column :running_backs, :position_rank, :integer
    add_column :running_backs, :nerd_rank, :float
    add_column :quarterbacks, :overall_rank, :integer
    add_column :quarterbacks, :position_rank, :integer
    add_column :quarterbacks, :nerd_rank, :float
    add_column :tight_ends, :overall_rank, :integer
    add_column :tight_ends, :position_rank, :integer
    add_column :tight_ends, :nerd_rank, :float
    add_column :defenses, :overall_rank, :integer
    add_column :defenses, :position_rank, :integer
    add_column :defenses, :nerd_rank, :float
    add_column :kickers, :overall_rank, :integer
    add_column :kickers, :position_rank, :integer
    add_column :kickers, :nerd_rank, :float
  end
end
