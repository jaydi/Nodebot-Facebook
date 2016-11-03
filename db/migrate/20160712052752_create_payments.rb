class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :message_id, index: true, null: false
      t.integer :pay_amount, null: false
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
