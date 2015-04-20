class CreateFolios < ActiveRecord::Migration
  def change
    create_table :folios do |t|
      t.integer :input_type_id
      t.string :folio_no
      t.string :remark
      t.integer :hotel_src_id

      t.timestamps
    end
  end
end
