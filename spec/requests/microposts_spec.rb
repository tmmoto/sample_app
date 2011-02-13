require 'spec_helper'

describe "Microposts" do
  before(:each) do
    user = Factory(:user)
    visit signin_path
    fill_in :email,     :with => user.email
    fill_in :password,  :with => user.password
    click_button
  end

  describe "creation" do
    
    describe "failure" do
      it "should not make a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          # Ie we are filling out an element on the page that is called "micropost_content", getting this from the css          
          click_button 
           response.should render_template('pages/home')
           # response.should have_selector('div#error_explanation')
           #Changed this as we changed the behaviour of the page
          #response.should redirect_to(root_path) 
          response.should have_selector('div.flash.error',  :content => "Content can't be blank")
        end.should_not change(Micropost, :count)
      end
    end
    
    describe "success" do
      it "should make a new micropost" do
        content = "Lorem ipsum"
        lambda do
          visit root_path
          fill_in :micropost_content, :with => content
          click_button
          response.should have_selector('span.content', :content => content)
        end.should change(Micropost, :count).by(1)
        
      end
    end
  end
end
