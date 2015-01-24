class AddFollowingToTwitterUsers < ActiveRecord::Migration
  def change
    add_column :twitter_users, :following, :json
  end
end
