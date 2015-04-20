class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :tel
      t.text :address
      t.integer :hotel_src_id

      t.timestamps
    end
  end
end
