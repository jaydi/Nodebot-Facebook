class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, index: true
      t.string :messenger_id, index: true
      t.string :encrypted_password
      t.string :encrypted_password_iv
      t.string :profile_pic
      t.string :name
      t.integer :balance, default: 0, null: false
      t.integer :price, default: 10000, null: false
      t.decimal :commission_rate, precision: 5, scale: 2, default: 30.00, null: false
      t.boolean :partner_agreements_accepted, default: false, null: false
      t.boolean :user_agreements_accepted, default: false, null: false
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
