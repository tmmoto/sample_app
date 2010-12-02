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
  
  def current_user?(user)
    user == current_user  
  end
  
  def signed_in?
    !current_user.nil?      # If the current user is not nil
  end

  def sign_out
    cookies.delete(:remember_token)
    current_user = nil
  end

  def request_signin # changed method name from deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  
  def store_location
    session[:return_to] = request.fullpath  # We are setting the session cookie
  end 
  
  def redirect_back_or(default)
    redirect_to session[:return_to] || default #  If we stored something in the session, redirect to that, or to the default value
    clear_return_to
  end 
  
  def clear_return_to
    session[:return_to] = nil  
  end
  
private
  
  def user_from_remember_token
    User.authenticate_with_salt(*get_remember_token) # * allows us to use an array of 2 elements where we suppos to pass 2 arguments
  end
    
  def get_remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end    
  
end
