class CreateCelebs < ActiveRecord::Migration
  def change
    create_table :celebs do |t|
      t.string :email, index: true, null: false
      t.string :password, null: false
      t.string :name, index: true, null: false
      t.string :profile_pic, null: false
      t.integer :price, null: false
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
