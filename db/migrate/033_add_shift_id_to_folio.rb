class AddShiftIdToFolio < ActiveRecord::Migration
  def change
    add_column :folios, :shift_id, :integer
    add_column :folios, :at_date, :date
  end
end
