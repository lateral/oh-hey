# app/jobs/twitter_user_add.rb
class TwitterUserAdd
  include Resque::Plugins::UniqueJob
  @queue = :twitter

  def self.perform(id, bot_id)
    TwitterUser.find(id).add
    Bot.find(bot_id).seed_results
  end
end
