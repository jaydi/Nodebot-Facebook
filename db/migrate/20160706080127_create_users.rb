class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, index: true, null: false
      t.string :encrypted_password, null: false
      t.string :encrypted_password_iv, null: false
      t.string :name, index: true
      t.string :profile_pic
      t.string :sender_id, index: true
      t.integer :status, index: true, null: false
      t.boolean :agreements_accepted, default: false
      t.timestamps null: false
    end
  end
end
