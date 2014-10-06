class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :remaining_data
      t.string :ip
      t.string :next_hop
      t.string :session_key
      t.integer :nonce
      t.timestamp :timestamp

      t.timestamps
    end
  end
end
