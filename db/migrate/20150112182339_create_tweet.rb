class CreateTweet < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.text :twitter_id
      t.text :url
      t.datetime :tweeted_at
      t.text :text
      t.references :twitter_user, index: true
      t.references :tweet_document, index: true

      t.timestamps null: false
    end
  end
end
