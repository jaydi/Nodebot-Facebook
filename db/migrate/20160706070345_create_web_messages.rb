class CreateWebMessages < ActiveRecord::Migration
  def change
    create_table :web_messages do |t|
      t.string :message_id
      t.string :sender_id, index: true, null: false
      t.integer :message_type, null: false
      t.integer :sequence
      t.text :text
      t.string :payload
      t.string :payload_url
      t.integer :sent_timestamp, limit: 8, null: false

      t.timestamps null: false
    end
  end
end
