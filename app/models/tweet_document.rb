# app/models/tweet_document.rb
class TweetDocument < ActiveRecord::Base
  has_many :tweet
end
