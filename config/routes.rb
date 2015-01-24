require 'resque/scheduler/server'

Rails.application.routes.draw do

  root to: 'application#index'

  post 'locations' => 'location#add'
  get 'data.json' => 'location#data'

  get 'test.json' => 'location#test'

  # Mount resque and protect it for production
  mount Resque::Server.new, at: '/administration/resque'

end
