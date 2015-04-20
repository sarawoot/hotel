class CreateFloors < ActiveRecord::Migration
  def change
    create_table :floors do |t|
      t.string :name
      t.integer :seq
      t.string :used, limit: 1, default: '1'
      t.integer :hotel_src_id
      t.timestamps
    end
  end
end
