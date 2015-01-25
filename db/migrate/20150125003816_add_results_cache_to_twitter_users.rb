class AddResultsCacheToTwitterUsers < ActiveRecord::Migration
  def change
    add_column :twitter_users, :results_cache, :json
  end
end
