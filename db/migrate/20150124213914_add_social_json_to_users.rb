class AddSocialJsonToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_json, :json
    add_column :users, :twitter_json, :json
  end
end
