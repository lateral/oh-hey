FactoryGirl.define do
  factory :twitter_user do
    twitter_username Faker::Internet.user_name
  end

  factory :tweet_document do
    url Faker::Internet.url
    body Faker::Lorem.paragraph
  end
end
