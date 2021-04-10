class HomeController < ApplicationController
  def index
    @users = User.all.limit(20).order(created_at: :desc)
  end

  #show user relationship
  def details
    @user = User.find_by(token: params[:user_token])
    @friends = @user.friend.where(status: "accept") unless @user.friend.empty?
    @pending = @user.friend.where(status: "pending")
  end
end
