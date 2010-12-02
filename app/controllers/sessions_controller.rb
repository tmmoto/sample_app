class SessionsController < ApplicationController
  
  def new
    @title ="Sign in"
  end
  
  def create
    user = User.authenticate( params[:session][:email], 
                              params[:session][:password] )
                              
    if user.nil? 
      flash.now[:error] = "Invalid email/password combination."  #Without flash.now, flash will be descplayed in the render new (part of current request), and the next request a
      @title ="Sign in"
      render 'new'    # In case of a failed create, we want to render the 'new' page layout
    else
      # Handle successful signin
      sign_in user
      redirect_back_or user
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end

end
