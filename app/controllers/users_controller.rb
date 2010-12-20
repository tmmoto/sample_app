class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :index] 
  before_filter :correct_user, :only => [:edit, :update]
  
  def index
    @title = "All users"
    @users = User.paginate(:page =>params[:page])   # Note here that we are using an @users variable, in plurral, in all other actions we used singular
  end
  
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
  
  def edit
    @user  = User.find(params[:id])
    @title = "Edit user"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      # It worked
      redirect_to @user, :flash => { :success => "Profile updated"} 
    else
      @title = "Edit user"
      render 'edit'      
    end
  end
  
private 

  def authenticate   
    request_signin unless signed_in?
  end
  
  def correct_user
    @user = User.find(params[:id]) 
    redirect_to(root_path) unless current_user?(@user)
  end  
end


