class AddColumnsToMessages < ActiveRecord::Migration
  def change
    change_column :messages, :sender_id, :integer, null: true
    add_column :messages, :sender_name, :string, null: false, default: '', after: :sender_id
    add_column :messages, :receiver_name, :string, null: false, default: '', after: :receiver_id
  end
end
