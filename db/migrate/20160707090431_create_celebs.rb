class CreateCelebs < ActiveRecord::Migration
  def change
    create_table :celebs do |t|
      t.string :email, index: true, null: false
      t.string :encrypted_password, null: false
      t.string :encrypted_password_iv, null: false
      t.string :name, index: true
      t.string :profile_pic
      t.integer :price, default: 10000, null: false
      t.string :auth_token, index: true
      t.datetime :auth_tokened_at
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
