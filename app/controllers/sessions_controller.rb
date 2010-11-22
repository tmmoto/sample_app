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
      render 'new'    # In case of a failed create, we want to rerender the 'new' page
    else
      # Handle successful signin
    end    
  end
  
  def destroy
    
  end

end
