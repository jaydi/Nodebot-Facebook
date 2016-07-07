class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :sender_id, index: true, null: false
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
