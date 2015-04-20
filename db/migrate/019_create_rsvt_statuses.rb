class CreateRsvtStatuses < ActiveRecord::Migration
  def change
    create_table :rsvt_statuses do |t|
      t.string :name
      t.string :used, limit: 1, default: '1'
      t.integer :hotel_src_id
      t.string :status, limit: 1
      t.timestamps
    end
  end
end
