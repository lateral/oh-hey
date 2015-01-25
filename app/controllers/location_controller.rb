class LocationController < ApplicationController
  skip_before_filter :verify_authenticity_token
  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  NEWS_API = LateralRecommender::API.new ENV['API_KEY'], 'news'
  GITHUB = Octokit::Client.new(login: 'ohheyseedhack', password: ENV['GITHUB_PASS'])

  def add
    @user = User.where(remote_id: params[:user_id]).first_or_create
    check_twitter
    check_github
    @user.distance = params[:proximity]
    @user.major = params[:major]
    @user.minor = params[:minor]
    render json: { success: @user.save }
  end

  def test
    user_a = User.find(1)
    user_b = User.find(2)
    render json: { repos: union }#.to_hash, b: b.to_hash }
  end

  # What display on Twitter when not two people?
  def data
    active_users = User.order('distance ASC').where("distance = 'NEAR' OR distance = 'IMMEDIATE'").limit(2)
    return render json: [], callback: params['callback'] if active_users.count < 1
    data = { users: active_users }
    twitter_1 = twitter_user(active_users[0])
    if active_users.length == 2
      twitter_2 = twitter_user(active_users[1])
      data[:mutual_github] = mutual_github(active_users[0], active_users[1])
      data[:mutual_following] = mutual_following(twitter_1, twitter_2)
      data[:news] = mutual_news(twitter_1, twitter_2)
    else
      data[:news] = news(twitter_1.id)[0..4]
    end
    render json: data, callback: params['callback']
  end

  private

  def github_info(data)
    data.map do |item|
      { id: item[:id], title: item[:full_name], description: item[:description],
        language: item[:language], stars: item[:stargazers_count],
        updated: item[:updated_at] }
    end
  end

  def mutual_github(a, b)
    stars_a = github_info(GITHUB.starred(a.github))
    subs_a = github_info(GITHUB.subscriptions(a.github))
    stars_b = github_info(GITHUB.starred(b.github))
    subs_b = github_info(GITHUB.subscriptions(b.github))
    stats_a = stars_a.concat(subs_a)
    stats_b = stars_b.concat(subs_b)
    stats_a.each_with_object([]) do |repo_a, arr|
      match = stats_b.detect { |repo_b| repo_b[:id] == repo_a[:id] }
      arr << match if match
    end
  end

  def mutual_news(a, b)
    news_1 = news(a.id)
    news_2 = news(b.id)
    news_1.concat(news_2).uniq { |result| result[:id] }.sort { |a, b| a[:distance].to_f <=> b[:distance].to_f }[0..4]
  end

  def news(user_id)
    results = NEWS_API.near_user user_id
    results.reject! { |item| item['summary'].blank? }[0..5]
    results.map do |result|
      summary = truncate(CGI.unescapeHTML(strip_tags(result['summary'])), length: 150, separator: ' ')
      published = DateTime.parse result['published']
      published = published.strftime '%d %^b at %H:%M'
      { id: result['document_id'], title: result['title'], summary: summary, distance: result['distance'],
        published: published, source: result['source_name'], source_slug: result['source_slug'] }
    end
  end

  def twitter_user(user)
    TwitterUser.find_by(twitter_username: user.twitter)
  end

  def twitter_self(username)
    user = TW_CLIENT.user(username)
    { id: user.id, photo: user.profile_image_url.to_s, description: user.description,
      name: user.name, username: user.screen_name,
      followers: user.followers_count }
  end

  def github_self(username)
    user = GITHUB.user(username)
    { id: id, name: user.name, username: user.login, photo: user.avatar_url,
      joined: user.created_at }
  end

  def mutual_following(a, b)
    return [] unless a.following && b.following
    users = TW_CLIENT.users(a.following & b.following, include_entities: false)
    users.map do |user|
      { id: user.id, photo: user.profile_image_url.to_s,
        name: user.name, username: user.screen_name,
        followers: user.followers_count }
    end
  end

  def check_twitter
    return unless params[:twitter]
    return if @user.twitter && @user.twitter == params[:twitter]
    # @user.twitter_json = twitter_self(params[:twitter])
    @user.twitter = params[:twitter]
    @user.save
  end

  def check_github
    return unless params[:github]
    return if @user.github && @user.github == params[:github]
    @user.github_json = github_self(params[:github])
    @user.github = params[:github]
    @user.save
  end
end
