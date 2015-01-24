# app/models/user.rb
class User < ActiveRecord::Base
  has_many :twitter_users
  after_save :update_social

  def update_social
    update_twitter if twitter_changed?
  end

  private

  def update_twitter
    # Update existing one
    u = TwitterUser.find_by twitter_username: twitter
    if u
      Resque.enqueue(TwitterUserUpdate, u.id)
    else
      # Need to add a new user
      u = TwitterUser.create twitter_username: twitter
      Resque.enqueue(TwitterUserAdd, u.id)
    end
  end
end
