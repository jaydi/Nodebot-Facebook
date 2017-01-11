class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :initial_message_id, index: true
      t.integer :sender_id, index: true, null: false
      t.integer :receiver_id, index: true, null: false
      t.text :text
      t.string :video_url
      t.integer :kind, index: true, null: false
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
