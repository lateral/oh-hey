require 'resque/scheduler/server'

Rails.application.routes.draw do

  # Mount resque and protect it for production
  mount Resque::Server.new, at: '/administration/resque' unless Rails.env.production?

end
