class MicropostsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      # flash[:success] = "Micropost created"
      redirect_to root_path, :flash => {:success  =>"Micropost created!"}   
    else  
      #@feed_items = []
      #render 'pages/home'
      redirect_to root_path, :flash => {:error => @micropost.errors.full_messages[0]}
    end  
  end
  
  def destroy
    # raise @micropost.inspect 
    @micropost.destroy  #we can reference the @micropost here, because we created the before_filter 
    redirect_to root_path, :flash => {:success  =>"Micropost deleted!"} 
  end
  
private
  
  def authorized_user
    @micropost = Micropost.find(params[:id])
    redirect_to root_path unless current_user?(@micropost.user)
  end  
  
end