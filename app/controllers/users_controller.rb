class UsersController < ApplicationController
 
  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def new
    @title = "Sign up"
    @user = User.new    # Creating a raw user object here, not yet saved in the database.
  end
  
  def create
    #raise params[:user].inspect # Inspect shows a string representation of an object (lesson 4)

    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      # Handle a succesful save
      flash[:success] = "Welcome to the Sample App!"
      redirect_to user_path(@user)  # we could also use redirect_to @user
       
      # This could be refactored also 
      # redirect_to user_path(@user), :flash => {:success => "Welcome to the Sample App!"}
    else
      @title = "Sign up"
      render 'new' 
    end
  end
end


