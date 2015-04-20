class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :hotel_src_id
      t.decimal :price
      t.string :category, limit: 1
      t.string :config, limit: 1
      t.string :used, limit: 1, default: '1'
      t.integer :product_place_id

      t.timestamps
    end
  end
end
