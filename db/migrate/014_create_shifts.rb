class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.string :name
      t.time :start_at
      t.time :end_at
      t.string :used, limit: 1, default: '1'
      t.integer :hotel_src_id
      t.timestamps
    end
  end
end
