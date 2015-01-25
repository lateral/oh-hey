class AddLastNearToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_near, :datetime
  end
end
