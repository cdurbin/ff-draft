class AddReturnYards < ActiveRecord::Migration
  def change
    add_column :running_backs, :punt_return_yards, :integer, default: 0
    add_column :running_backs, :kickoff_return_yards, :integer, default: 0
    add_column :wide_receivers, :punt_return_yards, :integer, default: 0
    add_column :wide_receivers, :kickoff_return_yards, :integer, default: 0
  end
end
