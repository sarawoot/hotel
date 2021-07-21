class AddAtDateToOutStanding < ActiveRecord::Migration
  def change
    add_column :out_standings, :at_date, :date
  end
end
