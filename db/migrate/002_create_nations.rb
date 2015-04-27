class CreateNations < ActiveRecord::Migration
  def change
    create_table :nations do |t|
      t.string :name
      t.string :used, limit: 1, default: '1'
      t.integer :hotel_src_id
      t.timestamps
    end
  end
end