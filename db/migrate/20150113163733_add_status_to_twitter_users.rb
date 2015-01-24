class AddStatusToTwitterUsers < ActiveRecord::Migration
  def change
    add_column :twitter_users, :status, :string, default: 'pending', index: true
  end
end
