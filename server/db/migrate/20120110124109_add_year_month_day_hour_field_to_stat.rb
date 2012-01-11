class AddYearMonthDayHourFieldToStat < ActiveRecord::Migration
  def change
    add_column :stats, :created_at_year, :integer
    add_column :stats, :created_at_month, :integer
    add_column :stats, :created_at_day, :integer
    add_column :stats, :created_at_hour, :integer
  end
end
