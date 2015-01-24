# app/jobs/twitter_user_add.rb
class TwitterUserAdd
  include Resque::Plugins::UniqueJob
  @queue = :twitter

  def self.perform(id)
    TwitterUser.find(id).add
  end
end
