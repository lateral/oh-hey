class LocationController < ApplicationController
  skip_before_filter :verify_authenticity_token
  include ApplicationHelper

  def add
    @user = User.where(remote_id: params[:user_id]).first_or_create
    check_twitter
    check_github
    @user.distance = params[:distance]
    @user.major = params[:major]
    @user.minor = params[:minor]
    render json: { success: @user.save }
  end

  def test
    user_a = User.find(1)
    user_b = User.find(2)
    stars_a = github_info(Octokit.starred(user_a.github))
    subs_a = github_info(Octokit.subscriptions(user_a.github))
    stars_b = github_info(Octokit.starred(user_b.github))
    subs_b = github_info(Octokit.subscriptions(user_b.github))

    stats_a = stars_a.concat(subs_a)
    stats_b = stars_b.concat(subs_b)
    union = stats_a.each_with_object([]) do |repo_a, arr|
      match = stats_b.detect { |repo_b| repo_b['title'] == repo_a['title'] }
      arr << match if match
    end
    render json: { repos: union }#.to_hash, b: b.to_hash }
  end

  # What display on Twitter when not two people?
  def data
    news_api = LateralRecommender::API.new ENV['API_KEY'], 'news'
    active_users = User.order('distance ASC').where('distance < 10.0').limit(2)
    return render json: [] if active_users.count < 1
    data = { users: active_users }
    twitter_1 = twitter_user(active_users[0])
    if active_users.length == 2
      twitter_2 = twitter_user(active_users[1])
      data[:mutual_following] = mutual_following(twitter_1, twitter_2)
    else
      data[:news] = news_api.near_user(twitter_1.id)
    end
    render json: data, callback: params['callback']
  end

  private

  def github_info(data)
    data.map do |item|
      { title: item[:full_name], description: item[:description],
        language: item[:language], stars: item[:stargazers_count],
        updated: item[:updated_at] }
    end
  end

  def twitter_user(user)
    TwitterUser.find_by(twitter_username: user.twitter)
  end

  def mutual_following(a, b)
    return [] unless a.following && b.following
    a.following.each_with_object([]) do |user_a, arr|
      match = b.following.detect { |user_b| user_b['id'] == user_a['id'] }
      arr << match if match
    end
  end

  def check_twitter
    return unless params[:twitter]
    return if @user.twitter && @user.twitter == params[:twitter]
    @user.twitter = params[:twitter]
    @user.save
  end

  def check_github
    return unless params[:github]
    return if @user.github && @user.github == params[:github]
    @user.github = params[:github]
    @user.save
  end
end
