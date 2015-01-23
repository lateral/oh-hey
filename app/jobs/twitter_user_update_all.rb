# app/jobs/twitter_user_update_all.rb
class TwitterUserUpdateAll
  include Resque::Plugins::UniqueJob
  @queue = :twitter

  def self.perform
    TwitterUser.where(status: 'active').each do |user|
      Resque.enqueue(TwitterUserUpdate, user.id)
    end
  end
end
