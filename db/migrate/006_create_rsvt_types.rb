class CreateRsvtTypes < ActiveRecord::Migration
  def change
    create_table :rsvt_types do |t|
      t.string :name
      t.string :used, limit: 1, default: '1'
      t.integer :hotel_src_id
      t.timestamps
    end
  end
end
