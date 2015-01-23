# app/jobs/twitter_user_update.rb
class TwitterUserUpdate
  include Resque::Plugins::UniqueJob
  @queue = :twitter

  def self.perform(id)
    TwitterUser.find(id).update
  end
end
