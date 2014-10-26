class AddSalaryToWeeklyRankings < ActiveRecord::Migration
  def change
    add_column :weekly_rankings, :salary, :integer, default: 0
  end
end
