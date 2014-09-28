class AddNextHopToUsers < ActiveRecord::Migration
  def change
    add_column :users, :next_hop, :string
  end
end
