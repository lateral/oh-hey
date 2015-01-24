# app/models/tweet.rb
class Tweet < ActiveRecord::Base
  belongs_to :twitter_user
  belongs_to :tweet_document

  def self.create_from_tweet(tweet, user)
    unless tweet[:doc].is_a?(TweetDocument)
      tweet[:doc] = TweetDocument.find_or_initialize_by tweet[:doc]
    end
    t = Tweet.find_or_initialize_by twitter_id: tweet[:id].to_s, text: tweet[:text],
                                    url: tweet[:urls].first.to_s, tweeted_at: tweet[:created_at],
                                    tweet_document: tweet[:doc], twitter_user: user
    t.save
    user.status = 'active'
    user.save
  end
end
