class ChangeMessages < ActiveRecord::Migration
  def change
    change_column :messages, :receiver_id, :integer, null: true
  end
end
