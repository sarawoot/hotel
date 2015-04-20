class CreateHotelSrcs < ActiveRecord::Migration
  def change
    create_table :hotel_srcs do |t|
      t.string :name

      t.timestamps
    end
  end
end
