require 'spec_helper'

describe "Users" do

  describe "signup" do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => ""
          fill_in "Email",        :with => ""
          fill_in "Password",     :with => ""
          fill_in "Confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end

    describe "success" do

      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => "Example User"
          fill_in "Email",        :with => "user@2example.com"
          fill_in "Password",     :with => "foobar"
          fill_in "Confirmation", :with => "foobar"
          click_button
          # Testing here for what appears on the rendered page, ie if the flash message will show up on the page 
          # In the unit test, we were only testing for the exsitance of a message in the flash hash, but not actually showing up
          #on the page
          response.should have_selector('div.flash.success', :content => "Welcome") 
          
          #Testing this if we are ing to the show page after success
          response.should render_template('users/show')
        end.should change(User, :count).by(1)
      end
    end
    
    describe "signin" do
      describe "failure" do
        it "should not sign a user in" do
          visit signin_path
          fill_in :email, :with => ""
          fill_in :password, :with => ""
          click_button
          response.should have_selector('div.flash.error',  :content => "Invalid")
          response.should render_template('sessions/new')
        end        
      end
      
      describe "success" do
        it "should sign a user in and out" do
          visit signin_path
          user = Factory(:user)
          fill_in "Email",    :with => user.email
          fill_in "Password", :with => user.password
          click_button
          controller.should be_signed_in
          click_link "Sign out"
          controller.should_not be_signed_in 
        end
      end
    end
  end
end