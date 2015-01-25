# app/models/twitter_user.rb
class TwitterUser < ActiveRecord::Base
  # has_many :tweets, dependent: :destroy
  belongs_to :user

  API = LateralRecommender::API.new ENV['API_KEY']
  NEWS_API = LateralRecommender::API.new ENV['API_KEY'], 'news'

  def update
    API.add_user(id)
    last_tweet = Tweet.where(twitter_user: self).order('tweeted_at ASC').last
    last_tweet = { twitter_id: 100 } if last_tweet.nil?
    tweets = meaningful_tweets(users_tweets(since_id: last_tweet[:twitter_id]))
    tweets.each { |tweet| Tweet.create_from_tweet tweet, self }
  end

  def add
    API.add_user(id)
    tweets = meaningful_tweets(users_tweets)
    tweets.each { |tweet| Tweet.create_from_tweet tweet, self }
    save_following
    self.results_cache = NEWS_API.near_user(id)
    save!
  end

  def save_following
    friends = TW_CLIENT.friend_ids(twitter_username, skip_status: true, include_user_entities: false).to_a
    self.following = friends
    save!
  end

  # private

  def meaningful_tweets(tweets)
    # Get tweets with links in
    tweets = cached_articles(tweets)

    # Compile a list of URLs that need to be fetched
    urls_to_fetch = tweets.map { |tweet| tweet[:urls].first unless tweet.key?(:doc) }

    # Pass to MultiUrlBoilerpipe to fetch them in parallel
    bodies = batch_article_bodies(urls_to_fetch)
    # Loop through each tweet in parallel to check with the API
    check_articles_with_api(tweets, bodies)
  end

  def check_articles_with_api(tweets, bodies)
    threads = Rails.env.test? ? 0 : 8
    Parallel.map(tweets, in_threads: threads) do |tweet|
      # If the tweet already has a :doc key then it's cached
      if tweet.key? :doc
        response = API.add_user_document(id, tweet[:id], tweet[:doc][:body], created_at: tweet[:created_at])
        # response
        tweet
      else
        # Create a temporary document object and send the body to the API
        tweet[:doc] = { url: tweet[:urls].first, body: bodies[tweet[:urls].first] }
        response = API.add_user_document(id, tweet[:id], tweet[:doc][:body], created_at: tweet[:created_at])
        # response
        # Return the tweet if the API response is valid
        tweet unless response.key?(:error)
      end
    end.reject(&:blank?)
  end

  def batch_article_bodies(urls)
    threads = Rails.env.test? ? 0 : 8
    parser = DocumentParser.new
    Hash[Parallel.map(urls, in_threads: threads) { |url| [url, parser.pocket(url)] }]
  end

  def cached_articles(tweets)
    docs = TweetDocument.where(url: tweets.map { |tweet| tweet[:urls].first })
    docs.each { |doc| tweets.find { |t| t[:urls].first == doc.url }[:doc] = doc }
    tweets
  end

  def users_tweets(opts = {})
    api_opts = { count: 50, include_rts: 1, trim_user: 1 }.merge(opts)
    tweets_with_links TW_CLIENT.user_timeline(twitter_username, api_opts)
  end

  def tweets_with_links(tweets)
    tweets.each_with_object([]) do |tweet, arr|
      next unless tweet.entities? && tweet.urls.length > 0
      arr << {
        id: tweet.id, url: tweet.urls.first.to_s, created_at: tweet.created_at, text: tweet.text,
        urls: tweet.urls.map { |url| url.expanded_url.to_s }, original: tweet
      } if tweet.urls.length > 0
    end
  end
end
