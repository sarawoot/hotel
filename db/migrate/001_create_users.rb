class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :username
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.string :lang, default: "en"
      t.string :role, default: "user"
      t.integer :hotel_src_id
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
