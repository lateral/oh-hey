class AddGithubFavsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_favs, :json
  end
end
