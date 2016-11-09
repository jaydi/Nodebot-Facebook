class CreateExchangeRequests < ActiveRecord::Migration
  def change
    create_table :exchange_requests do |t|
      t.references :celeb, null: false
      t.references :bank, null: false
      t.string :account_holder, null: false
      t.string :encrypted_account_number, null: false
      t.string :encrypted_account_number_iv, null: false
      t.integer :amount, null: false
      t.integer :status, null: false
      t.timestamps null: false
    end
  end
end