class AddLotsTakenAndLotsTotalToParkingramps < ActiveRecord::Migration
  def change
    add_column :parkingramps, :lots_taken, :integer, :default => 0
    add_column :parkingramps, :lots_total, :integer, :default => 0
  end
end
