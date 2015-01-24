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
    # return u.update if u
    return Resque.enqueue(TwitterUserUpdate, u.id) if u

    # Need to add a new user
    u = TwitterUser.create twitter_username: twitter
    # u.add
    Resque.enqueue(TwitterUserAdd, u.id)
  end
end
