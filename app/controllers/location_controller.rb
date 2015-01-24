class LocationController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def add
    @user = User.where(remote_id: params[:user_id]).first_or_create
    check_twitter
    # twitter/github
    render json: { user: @user }
  end

  private

  def check_twitter
    # Return if no twitter param
    return unless params[:twitter]

    # Return if users twitter hasn't changed
    return if @user.twitter && @user.twitter == params[:twitter]

    # Update the users twitter
    @user.twitter = params[:twitter]
    @user.save
  end
end
