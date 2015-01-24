class AddDistanceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :distance, :float
  end
end
