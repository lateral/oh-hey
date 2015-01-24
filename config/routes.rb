require 'resque/scheduler/server'

Rails.application.routes.draw do

  root to: 'application#index'

  post 'locations' => 'location#add'

  # Mount resque and protect it for production
  mount Resque::Server.new, at: '/administration/resque'

end
