class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :name, limit: 36
      t.string :code, limit: 8
      t.timestamps null: false
    end
  end
end