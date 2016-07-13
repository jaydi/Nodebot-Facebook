class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :sender_id, index: true, null: false
      t.integer :celeb_id
      t.string :name, null: false
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
