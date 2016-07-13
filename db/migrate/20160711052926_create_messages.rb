class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :initial_message_id, index: true
      t.integer :sending_user_id, index: true, null: false
      t.integer :receiving_user_id, index: true, null: false
      t.text :text
      t.string :video_url
      t.integer :status, index: true, null: false
      t.timestamps null: false
    end
  end
end
