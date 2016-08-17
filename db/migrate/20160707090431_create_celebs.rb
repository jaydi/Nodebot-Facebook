class CreateCelebs < ActiveRecord::Migration
  def change
    create_table :celebs do |t|
      t.string :email, index: true, null: false
      t.string :encrypted_password, null: false
      t.string :name, index: true
      t.string :profile_pic
      t.integer :price, null: false, default: 100000
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
