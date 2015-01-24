class LocationController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def add
    render json: params
  end
end
