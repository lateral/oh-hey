class CreateTweetDocument < ActiveRecord::Migration
  def change
    create_table :tweet_documents do |t|
      t.text :url
      t.text :body

      t.timestamps null: false
    end
  end
end
