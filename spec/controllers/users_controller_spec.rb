require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do

    before(:each) do
      #@user = User.create!({:name => 'Tibor', :email => 't@tt.com', :password => 'foobar', :password_confirmation => 'foobar'})
      @user = Factory(:user)   # :user is a class that we defined in the factories.rb
    end

    it "should be successful" do
      get :show, :id => @user.id  # Could use @user as well, due the flexibility of rails
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user.id
      assigns(:user).should == @user  # assign method from RSpec will will return the @user symbol in the controller. 
      #So we are testing here if the show action really returning the right object here
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  it "should be succesful" do
    get :new
    response.should have_selector('title', :content => "Sign Up")
  end
end
