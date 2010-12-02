require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after signing in" do
    user = Factory(:user)
    visit edit_user_path(user) 
    fill_in :email,     :with => user.email
    fill_in :password,  :with => user.password  # WHile doing the integration test, we will be redirected to the signup page
    click_button
    response.should render_template('users/edit')  # Testing here that after we signed in, it will really take use to the page that we oringally wanted
    
    # And now testing to make sure that after signing in again we don't end up redirecting to the destination page
    visit signout_path
    visit signin_path
    fill_in :email,     :with => user.email
    fill_in :password,  :with => user.password
    click_button
    response.should render_template('users/show') 
  end
end
