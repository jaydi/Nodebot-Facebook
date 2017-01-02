class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :message_id, index: true, null: false
      t.integer :pay_amount, null: false
      t.decimal :commission_rate, precision: 5, scale: 2, null: false
      t.string :failure_reason
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
