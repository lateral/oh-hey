class CreateTwitterUser < ActiveRecord::Migration
  def change
    create_table :twitter_users do |t|
      t.text :twitter_username

      t.timestamps null: false
    end
  end
end
