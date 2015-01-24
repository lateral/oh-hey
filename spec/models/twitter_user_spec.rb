require 'spec_helper'

describe TwitterUser, type: :model do

  let(:user) { FactoryGirl.create :twitter_user, twitter_username: 'maxnovakovic' }
  let(:existing_url) { 'http://www.datapointed.net/2014/10/maps-of-street-grids-by-orientation/' }
  before(:each) do
    @doc = FactoryGirl.create :tweet_document, url: existing_url
    allow_any_instance_of(LateralRecommender::API).to receive(:add_user).and_return(success: true)
    allow_any_instance_of(LateralRecommender::API).to receive(:add_user_document).and_return(success: true)
  end

  # describe '#update' do
  #   it 'updates a users Tweets' do
  #     # Start with some tweets
  #     VCR.use_cassette('twitter_user/meaningful_tweets') { user.send(:add) }
  #     count = Tweet.where(twitter_user: user).count

  #     # Now update
  #     VCR.use_cassette('twitter_user/meaningful_tweets_update') do
  #       user.send(:update)
  #       expect(Tweet.where(twitter_user: user).count).to eq(count + 1)
  #     end
  #   end
  # end

  describe '#add' do
    it 'creates Tweets and TweetDocuments for a user' do
      VCR.use_cassette('twitter_user/meaningful_tweets') do
        expect(Tweet.where(twitter_user: user).count).to eq(0)
        user.send(:add)
        expect(Tweet.where(twitter_user: user).count).to eq(33)
        expect(TweetDocument.count).to eq(33)
      end
    end
  end

  describe '#users_tweets' do
    it 'gets tweets with URLs from the Twitter API' do
      VCR.use_cassette('twitter_user/users_tweets') do
        tweets = user.send(:users_tweets)
        expect(tweets.length).to eq(33)
        expect(tweets.first[:urls].first).to include('nicholas-carr')
      end
    end
  end

  describe '#cached_articles' do
    it 'returns existing copies of cached articles' do
      VCR.use_cassette('twitter_user/users_tweets') do
        tweets = user.send(:users_tweets)
        cached_tweets = user.send(:cached_articles, tweets)
        cached_tweet = cached_tweets.find { |tweet| tweet[:doc] == @doc }
        expect(cached_tweet[:doc].body).to eq(@doc.body)
      end
    end
  end

  describe '#batch_article_bodies' do
    it 'fetches article bodies from the document parser' do
      VCR.use_cassette('twitter_user/batch_article_bodies') do
        tweets = user.send(:users_tweets)
        urls_to_fetch = tweets.map { |tweet| tweet[:urls].first }
        bodies = user.send(:batch_article_bodies, urls_to_fetch)
        expect(bodies.length).to eq(33)
      end
    end
  end

  describe '#meaningful_tweets' do
    it 'returns an array of all tweets with meaningful articles' do
      VCR.use_cassette('twitter_user/meaningful_tweets') do
        tweets = user.send(:users_tweets)
        meaningful_tweets = user.send(:meaningful_tweets, tweets)
        existing = meaningful_tweets.find { |tweet| tweet[:urls].first == existing_url }
        expect(existing).to be_truthy
        expect(meaningful_tweets.length).to eq(33)
      end
    end
  end

end
