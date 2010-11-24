module SessionsHelper
  
  def sign_in(user)
     cookies.permanent.signed[:remember_token] = [user.id, user.salt] #This actually expires 20 years from now
     current_user = user
   end
   
  def current_user=(user)   # This is a setter method that sets 
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def signed_in?
    !current_user.nil? # I the current user is no
  end

private
  
  def user_from_remember_token
    User.authenticate_with_salt(*get_remember_token) # * allows us to use an array of 2 elements where we suppos to pass 2 arguments
  end
    
  def get_remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end    
  
end
