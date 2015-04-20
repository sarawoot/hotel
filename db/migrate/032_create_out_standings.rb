class CreateOutStandings < ActiveRecord::Migration
  def change
    create_table :out_standings do |t|
      t.string :report
      t.string :room
      t.string :room_type
      t.string :gst_type
      t.string :gst_name
      t.date :arvl_at
      t.date :dpt_at
      t.decimal :room_rate
      t.decimal :ext_bed_rate
      t.decimal :folio
      t.decimal :credit
      t.timestamps
    end
  end
end
