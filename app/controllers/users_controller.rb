class UsersController < ApplicationController
 
  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def new
    @title = "Sign Up"
    @user = User.new    # Creating a raw user object here, not yet save in the database.
    
  end

end


