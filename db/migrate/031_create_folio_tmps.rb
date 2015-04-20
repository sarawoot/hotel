class CreateFolioTmps < ActiveRecord::Migration
  def change
    create_table :folio_tmps do |t|
      t.integer :folio_id      
      t.string :folio_no
      t.string :contact_name
      t.text :contact_address
      t.datetime :arvl_at
      t.datetime :dpt_at
      t.date :at_date
      t.string :room_no
      t.string :des
      t.decimal :debit
      t.decimal :credit
      t.string :ref
      t.string :username

      t.timestamps
    end
  end
end
