class CreateRateCodeDetails < ActiveRecord::Migration
  def change
    create_table :rate_code_details do |t|
      t.integer :rate_code_id
      t.integer :room_type_id
      t.decimal :room_rate, default: 0
      t.decimal :abf_rate, default: 0
      t.decimal :ext_bed_rate, default: 0
      t.integer :hotel_src_id
      t.timestamps
    end
  end
end
