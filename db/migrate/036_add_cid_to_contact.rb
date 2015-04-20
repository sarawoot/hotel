class AddCidToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :cid, :string
  end
end
